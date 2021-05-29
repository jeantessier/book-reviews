const { ApolloServer, gql } = require('apollo-server')
const { UserInputError } = require('apollo-server-errors')
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
        bookAdded: (key, book) => books.set(key, book),
        bookUpdated: (key, book) => books.set(key, book),
        bookRemoved: key => books.delete(key),
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

const addBook = async (_, { book }) => {
    const bookForName = fetchBookByName(book.name)
    if (bookForName) {
        throw new UserInputError(`Name "${book.name}" is already taken.`)
    }

    book.id = uuidv4()

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookAdded',
            ...book,
        }
    )

    return book
}

const updateBook = async (_, { update }) => {
    const book = fetchBookById(update.id)
    if (!book) {
        throw new UserInputError(`No book with ID "${update.id}".`)
    }

    if (update.name) {
        const bookForName = fetchBookByName(update.name)
        if (bookForName && bookForName.id !== book.id) {
            throw new UserInputError(`Name "${update.name}" is already taken.`)
        }
    }

    const bookUpdatedMessage = {
        ...book,
        ...update,
    }

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookUpdated',
            ...bookUpdatedMessage,
        }
    )

    return bookUpdatedMessage
}

const removeBook = async (_, { id }) => {
    const book = fetchBookById(id)
    if (!book) {
        throw new UserInputError(`No book with ID "${id}".`)
    }

    await sendMessage(
        'book-reviews.books',
        {
            type: 'bookRemoved',
            id,
        }
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
const fetchBookByName = name => {
    const bookEntry = Array.from(books.entries()).find(([_, book]) => book.name === name)
    return bookEntry ? bookEntry[1] : undefined
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
