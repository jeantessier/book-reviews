const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  extend type Book @key(fields: "bookId") {
    bookId: ID! @external
  }

  extend type Review @key(fields: "reviewId") {
    reviewId: ID! @external
  }

  extend type User @key(fields: "userId") {
    userId: ID! @external
  }

  union SearchResult = Book | Review | User

  input IndexInput {
    words: String!
    id: ID!
    typename: String!
  }

  type Query {
    search(q: String): [SearchResult!]!
  }

  type Mutation {
      addIndex(index: IndexInput): [SearchResult!]!
  }
`;

const indices = {};

const search = async (_, { q }) => {
  const results = [];

  q.toLowerCase().split(/\s+/).forEach(word => {
    if (word in indices) {
      Object.values(indices[word]).forEach(r => results.push(r));
    }
  });

  return results;
};

const addIndex = async (_, { index }) => {
  const results = [];

  console.log(`***   Starting addIndex()`);
  console.log(`***   index: ${index} (${typeof index}) [${JSON.stringify(index)}]`);
  console.log(`***   index.words: ${index.words} (${typeof index.words}) [${JSON.stringify(index.words)}]`);

  index.words.toLowerCase().split(/\s+/).forEach(word => {
    if (!(word in indices)) {
      console.log(`Creating index entry for "${word}"`);
      indices[word] = {};
    }
    if (!(index.id in indices[word])) {
      console.log(`Creating index entry for ${index.id} under "${word}"`);
      indices[word][index.id] = {
        __typename: index.typename,
        // Being lazy and setting all IDs.  Gateway will filter on __typename.
        bookId: index.id,
        reviewId: index.id,
        userId: index.id,
      }
      results.push(indices[word][index.id]);
    }
  });

  return results;
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
  Query: {
    search,
  },
  Mutation: {
    addIndex,
  },
};

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }]),
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log("Request did start!");
        console.log(`    query: ${requestContext.request.query}`);
        console.log(`    operationName: ${requestContext.request.operationName}`);
        console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`);
        console.log(`    indices: ${JSON.stringify(indices)}`);
      },
    },
  ],
});

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
