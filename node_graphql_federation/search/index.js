const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');

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

  indexWord(index.id, index, (i) => results.push(i));

  index.words.toLowerCase().split(/\s+/).forEach(word => {
    indexWord(word, index, (i) => results.push(i));
  });

  return results;
};

const indexWord = (word, index, addedIndexCallback) => {
  if (!(word in indices)) {
    console.log(`Creating index entry for "${word}"`);
    indices[word] = {};
  }
  if (!(index.id in indices[word])) {
    console.log(`Creating index entry for ${index.id} under "${word}"`);
    indices[word][index.id] = {
      __typename: index.typename,
      id: index.id,
    }
    addedIndexCallback(indices[word][index.id]);
  }
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves search results from the "indices"
// structure above.
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
        console.log(`====================   ${new Date().toJSON()}   ====================`);
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