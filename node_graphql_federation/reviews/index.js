const { ApolloServer, gql } = require('apollo-server')
const { UserInputError } = require('apollo-server-errors')
const { buildFederatedSchema } = require('@apollo/federation')
const { v4: uuidv4 } = require('uuid')

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('./kafka')

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
        bookRemoved: key => {
            [ ...reviews ].filter(([ _, review ]) => key === review.book.id).forEach(([ id, _ ]) => {
                sendMessage(
                    'book-reviews.reviews',
                    {
                        type: 'reviewRemoved',
                        id,
                    }
                )
            })
        },
        userRemoved: key => {
            [ ...reviews ].filter(([ _, review ]) => key === review.reviewer.id).forEach(([ id, _ ]) => {
                sendMessage(
                    'book-reviews.reviews',
                    {
                        type: 'reviewRemoved',
                        id,
                    }
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
  type Review @key(fields: "id") {
    id: ID!
    reviewer: User!
    book: Book!
    body: String!
    start: String
    stop: String
  }

  input AddReviewInput {
      reviewerId: ID!
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

const addReview = async (_, { review }) => {
    const { reviewerId, bookId, ...reviewAddedMessage } = review

    reviewAddedMessage.id = uuidv4()
    reviewAddedMessage.reviewer = { __typename: 'User', id: reviewerId }
    reviewAddedMessage.book = { __typename: 'Book', id: bookId }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewAdded',
            ...reviewAddedMessage,
        }
    )

    return reviewAddedMessage
}

const updateReview = async (_, { update }) => {
    const review = fetchReviewById(update.id)
    if (!review) {
        throw new UserInputError(`No review with ID "${update.id}".`)
    }

    const reviewUpdatedMessage = {
        ...review,
        ...update,
    }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewUpdated',
            ...reviewUpdatedMessage,
        }
    )

    return reviewUpdatedMessage
}

const removeReview = async (_, { id }) => {
    const review = fetchReviewById(update.id)
    if (!review) {
        throw new UserInputError(`No review with ID "${update.id}".`)
    }

    await sendMessage(
        'book-reviews.reviews',
        {
            type: 'reviewRemoved',
            id,
        }
    )

    return true
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
    Query: {
        reviews: async (_, { forReviewer }) => forReviewer ? reviews.filter(r => r.reviewer.id === forReviewer) : reviews.values(),
        review: async (_, { id }) => fetchReviewById(id),
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
const fetchReviewsByBookId = id => [ ...reviews ].filter(([ _, review ]) => id === review.book.id).map(([ _, review ]) => review)
const fetchReviewsByReviewerId = id => [ ...reviews ].filter(([ _, review ]) => id === review.reviewer.id).map(([ _, review ]) => review)

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
                    console.log("    reviews:")
                    dump(reviews)
                }
            },
        },
    ],
})

const port = process.env.PORT || 4002

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
