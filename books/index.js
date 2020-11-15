const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type Book @key(fields: "id") {
    id: ID!
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
    book(id: ID!): Book
  }

  type Mutation {
    addBook(book: BookInput): Book
  }
`;

const books = [];

const addBook = async (_, { book }) => {
  book.id = uuidv4();
  books.push(book);
  return book;
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
  Query: {
    books: async () => books,
    book: async (_, { id }) => fetchBookById(id),
  },
  Mutation: {
    addBook
  },
  Book: {
    __resolveReference(book) {
      return fetchBookById(book.id)
    }
  },
};

const fetchBookById = id => books.find(book => id === book.id);

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }]),
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log(`====================   ${new Date().toJSON()}   ====================`);
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
