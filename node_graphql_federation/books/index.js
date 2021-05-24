const { ApolloServer, gql } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')
const { v4: uuidv4 } = require('uuid')

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('./kafka')

const books = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const topicName = 'book-reviews.books'
startConsumer(
    groupId,
    topicName,
    {
        addBook: (key, book) => books.set(key, book),
        removeBook: key => books.delete(key),
    },
    () => {
        console.log("    books:")
        dump(books)
    }
).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group ${groupId}.`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
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

  input BookInput {
    name: String!
    titles: [TitleInput!]!
    authors: [String!]!
    publisher: String!
    years: [String!]!
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
    addBook(book: BookInput): Book
    removeBook(id: ID!): Boolean!
  }
`

const addBook = async (_, { book }) => {
    book.id = uuidv4()

    await sendMessage(
        'book-reviews.books',
        {
            type: 'addBook',
            ...book,
        }
    )

    return book
}

const removeBook = async (_, { id }) => {
    const found = fetchBookById(id) !== undefined

    if (found) {
        await sendMessage(
            'book-reviews.books',
            {
                type: 'removeBook',
                id,
            }
        )
    }

    return found
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
                console.log("    books:")
                dump(books)
            },
        },
    ],
})

const port = process.env.PORT || 4001

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
