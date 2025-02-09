require('dotenv').config()

require ('./open-telemetry')

const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { gql } = require('graphql-tag')
const { v4: uuidv4 } = require("uuid")
const jwt = require('jsonwebtoken')

const { groupId, sendMessage, startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const indices = new Map()
const dump = map => map.forEach((index, word) => {
    console.log(`        ${word}:`)
    index.forEach((object, id) => {
        console.log(`          ${id}: ${JSON.stringify(object)}`)
    })
})

const topicName = /book-reviews.(books|reviews|users)/
startConsumer(
    groupId,
    topicName,
    {
        bookAdded: (_, book) => indexBook(book),
        bookUpdated: (_, book) => indexBook(book),
        bookRemoved: key => scrubIndices(key),
        reviewAdded: (_, review) => indexReview(review),
        reviewUpdated: (_, review) => indexReview(review),
        reviewRemoved: key => scrubIndices(key),
        userAdded: (_, user) => indexUser(user),
        userUpdated: (_, user) => indexUser(user),
        userRemoved: key => scrubIndices(key),
    },
    () => {
        if (process.env.DEBUG) {
            console.log("    indices:")
            dump(indices)
        }
    }
).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

const indexBook = book => {
    const corpus = [
        book.id,
        book.name,
        book.titles.map(title => normalize(title.title)),
        book.authors.map(author => normalize(author)),
        normalize(book.publisher),
        book.years,
    ].flat()
    updateIndex(
        corpus,
        {
            id: book.id,
            __typename: 'Book',
        }
    )
}

const indexReview = review => {
    const corpus = [
        review.id,
        normalize(review.body)
    ]
    if (review.start) {
        corpus.push(normalize(review.start))
    }
    if (review.stop) {
        corpus.push(normalize(review.stop))
    }
    updateIndex(
        corpus,
        {
            id: review.id,
            __typename: 'Review',
        }
    )
}

const indexUser = user => {
    const corpus = [
        user.id,
        normalize(user.name),
        user.email,
        user.email.replace(/@/, ' '),
    ]
    updateIndex(
        corpus,
        {
            id: user.id,
            __typename: 'User',
        }
    )
}

const scrubIndices = id => {
    updateIndex(
        [],
        {
            id,
        }
    )
}

const updateIndex = (corpus, indexEntry) => {
    const oldIndexEntries = findCurrentIndexEntries(indexEntry.id)
    if (process.env.DEBUG) {
        console.log('oldIndexEntries')
        oldIndexEntries.forEach((entry, word) => console.log(`    ${word}: ${JSON.stringify(entry)}`))
    }

    const newIndexEntries = computeNewIndexEntries(corpus, indexEntry)
    if (process.env.DEBUG) {
        console.log('newIndexEntries')
        newIndexEntries.forEach((entry, word) => console.log(`    ${word}: ${JSON.stringify(entry)}`))
    }

    Array
        .from(oldIndexEntries.keys())
        .filter(word => !newIndexEntries.has(word))
        .forEach(word => scrubIndex(word, indexEntry.id))

    newIndexEntries.forEach((scoredIndexEntry, word) => indexWord(word, scoredIndexEntry))
}

const findCurrentIndexEntries = id => {
    indexEntries = new Map()
    indices.forEach((index, word) => {
        if (index.has(id)) {
            indexEntries.set(word, index.get(id))
        }
    })
    return indexEntries
}

const computeNewIndexEntries = (corpus, indexEntry) => {
    indexEntries = new Map()

    const wordScores = new Map()
    corpus.forEach(words => {
        computeScoresForWords(words).forEach((score, word) => {
            wordScores.set(word, score + (wordScores.has(word) ? wordScores.get(word) : 0))
        })
    })

    wordScores.forEach((score, word) => indexEntries.set(word, {score, ...indexEntry}))

    return indexEntries
}

const computeScoresForWords = words => {
    scores = new Map()

    const wordScores = new Map()
    words.toLowerCase().split(/\s+/).filter(word => word).forEach(word => {
        wordScores.set(word, word.length + (wordScores.has(word) ? wordScores.get(word) : 0))
    })

    wordScores.forEach((score, word) => scores.set(word, score / words.length))

    return scores
}

const indexWord = (word, indexEntry) => {
    if (!(indices.has(word))) {
        if (process.env.DEBUG) {
            console.log(`Creating index for "${word}"`)
        }
        indices.set(word, new Map())
    }
    if (!(indices.get(word).has(indexEntry.id))) {
        if (process.env.DEBUG) {
            console.log(`Creating index entry for ${indexEntry.id} under "${word}" with score ${indexEntry.score}`)
        }
        indices.get(word).set(indexEntry.id, indexEntry)
    } else if (indices.get(word).get(indexEntry.id).score !== indexEntry.score) {
        if (process.env.DEBUG) {
            console.log(`Updating index entry for ${indexEntry.id} under "${word}", score was ${indices.get(word).get(indexEntry.id).score} and is now ${indexEntry.score}`)
        }
        indices.get(word).set(indexEntry.id, indexEntry)
    }
}

const scrubIndex = (word, id) => {
    if (process.env.DEBUG) {
        console.log(`Removing index entry for ${id} under "${word}"`)
    }
    indices.get(word).delete(id)
    if (indices.get(word).size === 0) {
        if (process.env.DEBUG) {
            console.log(`Removing empty index for "${word}"`)
        }
        indices.delete(word)
    }
}

const normalizationRules = new Map()
normalizationRules.set(/&(\w)(acute|uml|circ|grave|macr);/g, "$1")
normalizationRules.set(/&([mn]dash|nbsp);/g, " ")
normalizationRules.set(/&(ast|hellip|trade);/g, "")
normalizationRules.set(/&amp;/g, "&")

const normalize = text => {
    normalizationRules.forEach((mapping, entity) => text = text.replace(entity, mapping))
    return text
        .normalize('NFD')
        .replace(/\p{Diacritic}/gu, '')
        .replace(/[!?,;:&]/g, '')
        .replace(/[.'"`\-_*=#\/(){}\[\]<>]/g, ' ')
}

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

  extend type Book @key(fields: "id") {
    id: ID! @external
  }

  extend type Review @key(fields: "id") {
    id: ID! @external
  }

  extend type User @key(fields: "id") {
    id: ID! @external
  }

  union SearchResult = Book | Review | User

  type QueryPlan {
    words: [String!]!
    indices: [MatchingIndex!]!
    results: [MatchingResult!]!
  }

  type MatchingIndex {
    word: String!
    entries: [IndexEntry!]!
  }
  
  type IndexEntry {
    score: Float!
    id: ID!
    type: String!
  }
  
  type MatchingResult {
    weights: [MatchingResultWeight!]!
    totalWeight: Float!
    id: ID!
    type: String!
  }
  
  type MatchingResultWeight {
    word: String!
    weight: Float!
  }
  
  type Query {
    queryPlan(q: String!): QueryPlan!
    search(q: String!): [SearchResult!]!
    words: [String!]!
  }
`

const queryPlan = async (_, { q }) => {
    const plan = {
        words: normalize(q).toLowerCase().split(/\s+/),
        indices: [],
        results: [],
    }

    const resultsCollector = new Map()

    plan.words.forEach(word => {
        if (indices.has(word)) {
            plan.indices.push({
                word,
                entries: [ ...indices.get(word).values() ].map(indexEntry => {
                    return { type: indexEntry.__typename, ...indexEntry }
                }),
            })
            indices.get(word).forEach((indexEntry, id) => {
                if (resultsCollector.has(id)) {
                    resultsCollector.get(id).weights.push({ word, weight: indexEntry.score })
                    resultsCollector.get(id).totalWeight += indexEntry.score
                } else {
                    resultsCollector.set(id, { weights: [ { word, weight: indexEntry.score } ], totalWeight: indexEntry.score, id: indexEntry.id, type: indexEntry.__typename })
                }
            })
        }
    })

    plan.results = [ ...resultsCollector.values() ].sort((match1, match2) => match2.totalWeight - match1.totalWeight)

    return plan
}

const search = async (_, { q }, context) => {
    const resultsCollector = new Map()

    normalize(q).toLowerCase().split(/\s+/).forEach(word => {
        if (indices.has(word)) {
            indices.get(word).forEach((indexEntry, id) => {
                if (resultsCollector.has(id)) {
                    resultsCollector.get(id).weight += indexEntry.score
                } else {
                    const { score, ...match } = indexEntry
                    resultsCollector.set(id, { weight: score, ...match })
                }
            })
        }
    })

    const results = [ ...resultsCollector.values() ].sort((match1, match2) => match2.weight - match1.weight)

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.searches',
        {
            id: context.currentUser?.id,
            user: context.currentUser?.id,
            query: q,
            results,
        },
        headers,
    )

    return results
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves search results from the "indices"
// structure above.
const resolvers = {
    Query: {
        search,
        queryPlan,
        words: async () => indices.keys(),
    },
}

const server = new ApolloServer({
    schema: buildSubgraphSchema({ typeDefs, resolvers }),
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ${requestContext.contextValue.requestId}   ====================`)
                console.log("Request did start!")
                if (process.env.DEBUG) {
                    console.log(`    context: ${JSON.stringify(requestContext.contextValue)}`)
                }
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
                if (process.env.DEBUG) {
                    console.log("    indices:")
                    dump(indices)
                }
                console.log()
            },
        },
    ],
})

const getCurrentUser = (req) => {
    try {
        const authHeader = req.headers.authorization || ''
        if (!authHeader) return null

        const authHeaderParts = authHeader.split(' ')
        if (authHeaderParts.length < 2 || authHeaderParts[0].toLowerCase() !== 'bearer') return null

        const jwtPayload = jwt.verify(authHeaderParts[1], process.env.JWT_SECRET)

        return { id: jwtPayload.sub, ...jwtPayload }
    } catch (e) {
        console.warn(e)
        return null
    }
}

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
startStandaloneServer(server, {
    context: ({ req }) => {
        return {
            currentUser: getCurrentUser(req),
            requestId: req.headers["x-request-id"] || uuidv4(),
        }
    },
    listen: { port },
}).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
