const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { GraphQLError } = require('graphql')
const { gql } = require('graphql-tag')
const { v4: uuidv4 } = require('uuid')
const jwt = require('jsonwebtoken')

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const books = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const topicName = 'book-reviews.books'
startConsumer(
    groupId,
    topicName,
    {
        bookAdded: (key, book) => books.set(key, book),
        bookUpdated: (key, book) => books.set(key, book),
        bookRemoved: key => books.delete(key),
    },
    () => {
        if (process.env.DEBUG) {
            console.log("    books:")
            dump(books)
        }
    }
).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

  type Book @key(fields: "id") {
    id: ID!

    """
    a unique, URL-friendly name for the book for use in permalinks
    """
    name: String!

    """
    a shortcut to the first title in titles
    """
    title: String

    titles: [Title!]!
    authors: [String!]!
    publisher: String!
    years: [String!]!
  }

  type Title {
    title: String!
    link: String
  }

  input AddBookInput {
    name: String!
    titles: [TitleInput!]!
    authors: [String!]!
    publisher: String!
    years: [String!]!
  }

  input UpdateBookInput {
    id: ID!
    name: String
    titles: [TitleInput!]
    authors: [String!]
    publisher: String
    years: [String!]
  }

  input TitleInput {
    title: String!
    link: String
  }

  type Query {
    books: [Book!]!
    book(id: ID!): Book
  }

  type Mutation {
    addBook(book: AddBookInput): Book
    updateBook(update: UpdateBookInput): Book
    removeBook(id: ID!): Boolean!
  }
`

const addBook = async (_, { book }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (!context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation`)
    }

    const bookForName = fetchBookByName(book.name)
    if (bookForName) {
        throw new GraphQLError(`Name "${book.name}" is already taken.`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    book.id = uuidv4()

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookAdded',
            ...book,
        },
        headers,
    )

    return book
}

const updateBook = async (_, { update }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (!context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation`)
    }

    const book = fetchBookById(update.id)
    if (!book) {
        throw new GraphQLError(`No book with ID "${update.id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    if (update.name) {
        const bookForName = fetchBookByName(update.name)
        if (bookForName && bookForName.id !== book.id) {
            throw new GraphQLError(`Name "${update.name}" is already taken.`, {
                extensions: {
                    code: 'BAD_USER_INPUT',
                }
            })
        }
    }

    const bookUpdatedMessage = {
        ...book,
        ...update,
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookUpdated',
            ...bookUpdatedMessage,
        },
        headers,
    )

    return bookUpdatedMessage
}

const removeBook = async (_, { id }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (!context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation`)
    }

    const book = fetchBookById(id)
    if (!book) {
        throw new GraphQLError(`No book with ID "${id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookRemoved',
            id,
        },
        headers,
    )

    return true
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
    Query: {
        books: async () => books.values(),
        book: async (_, { id }) => fetchBookById(id),
    },
    Mutation: {
        addBook,
        updateBook,
        removeBook,
    },
    Book: {
        __resolveReference: async book => {
            return {
                ...book,
                ...fetchBookById(book.id),
            }
        },
        title: async book => fetchBookById(book.id)?.titles[0]?.title,
    },
}

const fetchBookById = id => books.get(id)
const fetchBookByName = name => Array.from(books.values()).find(book => book.name === name)

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
                    console.log("    books:")
                    dump(books)
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

const port = process.env.PORT || 4001

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
