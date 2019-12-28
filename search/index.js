const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  extend type Review @key(fields: "reviewId") {
    reviewId: ID! @external
  }

  input AddSearchResultInput {
      reviewId: ID!
  }

  type Query {
    search(q: String): [Review!]!
  }

  type Mutation {
      addSearchResult(searchResult: AddSearchResultInput): Review
  }
`;

const reviews = [];

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
  Query: {
    search: async (_, { q }) => reviews,
  },
  Mutation: {
    addSearchResult: async (_, { searchResult }) => {
      reviews.push(searchResult);
      return searchResult;
    },
  }
};

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }])
});

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
