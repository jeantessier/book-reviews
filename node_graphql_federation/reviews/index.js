require('dotenv').config()

require ('./open-telemetry')

const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { GraphQLError } = require('graphql')
const { gql } = require('graphql-tag')
const { v4: uuidv4 } = require('uuid')
const jwt = require('jsonwebtoken')

const { groupId, sendMessage, startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const reviews = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const reviewsTopicName = 'book-reviews.reviews'
startConsumer(
    groupId,
    reviewsTopicName,
    {
        reviewAdded: (key, review) => reviews.set(key, review),
        reviewUpdated: (key, review) => reviews.set(key, review),
        reviewRemoved: key => reviews.delete(key),
    },
    () => {
        if (process.env.DEBUG) {
            console.log("    reviews:")
            dump(reviews)
        }
    }
).then(() => {
    console.log(`Listening for "${reviewsTopicName}" messages as consumer group "${groupId}".`)
})

const booksAndUsersTopicName = /book-reviews.(books|users)/;
startConsumer(
    'reviews',
    booksAndUsersTopicName,
    {
        bookRemoved: (key, _, headers) => {
            [ ...reviews ].filter(([ _, review ]) => key === review.book.id).forEach(([ id, _ ]) => {
                sendMessage(
                    'book-reviews.reviews',
                    {
                        type: 'reviewRemoved',
                        id,
                    },
                    headers,
                )
            })
        },
        userRemoved: (key, _, headers) => {
            [ ...reviews ].filter(([ _, review ]) => key === review.reviewer.id).forEach(([ id, _ ]) => {
                sendMessage(
                    'book-reviews.reviews',
                    {
                        type: 'reviewRemoved',
                        id,
                    },
                    headers,
                )
            })
        }
    },
    () => {
        if (process.env.DEBUG) {
            console.log("    reviews:")
            dump(reviews)
        }
    }
).then(() => {
    console.log(`Listening for "${booksAndUsersTopicName}" messages as consumer group "reviews".`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

  type Review @key(fields: "id") {
    id: ID!
    reviewer: User!
    book: Book!
    body: String!
    start: String
    stop: String
  }

  input AddReviewInput {
    reviewerId: ID
    bookId: ID!
    body: String!
    start: String
    stop: String
  }

  input UpdateReviewInput {
    id: ID!
    body: String
    start: String
    stop: String
  }

  extend type User @key(fields: "id") {
    id: ID! @external
    reviews: [Review!]!
    books: [Book!]!
  }

  extend type Book @key(fields: "id") {
    id: ID! @external
    reviews: [Review!]!
    reviewers: [User!]!
  }

  type Query {
    reviews(forReviewer: ID): [Review!]!
    review(id: ID!): Review
  }

  type Mutation {
    addReview(review: AddReviewInput): Review
    updateReview(update: UpdateReviewInput): Review
    removeReview(id: ID!): Boolean!
  }
`

const addReview = async (_, { review }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }

    const { reviewerId, bookId, ...reviewAddedMessage } = review
    if (reviewerId && reviewerId !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on behalf of another user.`)
    }

    reviewAddedMessage.id = uuidv4()
    reviewAddedMessage.reviewer = { __typename: 'User', id: reviewerId ?? context.currentUser.id }
    reviewAddedMessage.book = { __typename: 'Book', id: bookId }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewAdded',
            ...reviewAddedMessage,
        },
        headers,
    )

    return reviewAddedMessage
}

const updateReview = async (_, { update }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }

    const review = fetchReviewById(update.id)
    if (!review) {
        throw new GraphQLError(`No review with ID "${update.id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }
    if (review.reviewer.id !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on behalf of another user.`)
    }

    const reviewUpdatedMessage = {
        ...review,
        ...update,
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewUpdated',
            ...reviewUpdatedMessage,
        },
        headers,
    )

    return reviewUpdatedMessage
}

const removeReview = async (_, { id }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }

    const review = fetchReviewById(id)
    if (!review) {
        throw new GraphQLError(`No review with ID "${id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }
    if (review.reviewer.id !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on behalf of another user.`)
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewRemoved',
            id,
        },
        headers,
    )

    return true
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
    Query: {
        reviews: async (_, { forReviewer }) => forReviewer ? reviews.filter(r => r.reviewer.id === forReviewer) : reviews.values(),
        review: async (_, { id }, context) => {
            const review = fetchReviewById(id)

            let headers = { request_id: context.requestId }
            if (context.currentUser) {
                headers["current_user"] = context.currentUser.id
            }

            await sendMessage(
                'book-reviews.views',
                {
                    __typename: 'Review',
                    id: id,
                },
                headers,
            )

            return review
        },
    },
    Mutation: {
        addReview,
        updateReview,
        removeReview,
    },
    Review: {
        __resolveReference: async review => {
            return {
                ...review,
                ...fetchReviewById(review.id),
            }
        },
    },
    Book: {
        reviews: async book => fetchReviewsByBookId(book.id),
        reviewers: async book => fetchReviewsByBookId(book.id).map(review => review.reviewer),
    },
    User: {
        reviews: async user => fetchReviewsByReviewerId(user.id),
        books: async user => fetchReviewsByReviewerId(user.id).map(review => review.book),
    },
}

const fetchReviewById = id => reviews.get(id)
const fetchReviewsByBookId = id => Array.from(reviews.values()).filter(review => id === review.book.id)
const fetchReviewsByReviewerId = id => Array.from(reviews.values()).filter(review => id === review.reviewer.id)

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
                    console.log("    reviews:")
                    dump(reviews)
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

const port = process.env.PORT || 4002

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
