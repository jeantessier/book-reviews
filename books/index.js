const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type Book @key(fields: "bookId") {
    bookId: ID!
    name: String!
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
  }

  type Mutation {
    addBook(book: BookInput): Book
  }
`;

const books = [];

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
  Query: {
    books: () => books,
  },
  Mutation: {
    addBook: async (_, { book }) => {
      book.bookId = uuidv4();
      books.push(book);
      return book;
    },
  },
  Book: {
    __resolveReference(book) {
      return fetchBookById(book.bookId)
    }
  }
};

const fetchBookById = bookId => books.find(book => bookId === book.bookId);

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }]),
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log("Request did start!");
        console.log(`    query: ${requestContext.request.query}`);
        console.log(`    operationName: ${requestContext.request.operationName}`);
        console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`);
        console.log(`    books: ${JSON.stringify(books)}`);
      },
    },
  ],
});

const port = process.env.PORT || 4001

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
