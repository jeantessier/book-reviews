const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');

require('dotenv').config();

const { sendMessage } = require('./kafka');

const indices = new Map();
const dump = map => map.forEach((index, word) => {
  console.log(`        ${word}:`)
  index.forEach((object, id) => {
    console.log(`          ${id}: ${JSON.stringify(object)}`)

  })
});


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

const search = async (_, { q }) => {
  const resultsCollector = new Map();

  q.toLowerCase().split(/\s+/).forEach(word => {
    if (indices.has(word)) {
      indices.get(word).forEach((match, id) => resultsCollector.set(id, match))
    }
  });

  const results = [...resultsCollector].map(([_, match]) => match);

  sendMessage(
      'book-reviews.searches',
      {
        query: q,
        results,
      }
  );

  return results;
};

const addIndex = async (_, { index }) => {
  const results = [];

  indexWord(index.id, index, i => results.push(i));

  index.words.toLowerCase().split(/\s+/).forEach(word => {
    indexWord(word, index, i => results.push(i));
  });

  return results;
};

const indexWord = (word, index, addedIndexCallback) => {
  if (!(indices.has(word))) {
    console.log(`Creating index entry for "${word}"`);
    indices.set(word, new Map());
  }
  if (!(indices.get(word).has(index.id))) {
    console.log(`Creating index entry for ${index.id} under "${word}"`);
    indices.get(word).set(
        index.id,
        {
          __typename: index.typename,
          id: index.id,
        }
    )
    addedIndexCallback(indices.get(word).get(index.id));
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
        console.log("    indices:");
        dump(indices);
      },
    },
  ],
});

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
