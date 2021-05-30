const { ApolloServer, gql } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('./kafka')

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
    console.log(`Listening for "${topicName}" messages as consumer group ${groupId}.`)
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
    words.toLowerCase().split(/\s+/).forEach(word => {
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

const normalize = text => text.replace(/[!?.&]/g, '')

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
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

  type Query {
    search(q: String!): [SearchResult!]!
  }
`

const search = async (_, { q }) => {
    const resultsCollector = new Map()

    q.toLowerCase().split(/\s+/).forEach(word => {
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

    const results = [ ...resultsCollector ].map(([ _, match ]) => match).sort((match1, match2) => match2.weight - match1.weight)

    await sendMessage(
        'book-reviews.searches',
        {
            query: q,
            results,
        }
    )

    return results
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves search results from the "indices"
// structure above.
const resolvers = {
    Query: {
        search,
    },
}

const server = new ApolloServer({
    schema: buildFederatedSchema([ { typeDefs, resolvers } ]),
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ====================`)
                console.log("Request did start!")
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
                if (process.env.DEBUG) {
                    console.log("    indices:")
                    dump(indices)
                }
            },
        },
    ],
})

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
