const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type User @key(fields: "userId") {
    userId: ID!
    name: String!
    email: String!
  }

  input UserInput {
      name: String!
      email: String!
  }

  type Query {
    users: [User!]!
  }

  type Mutation {
    addUser(user: UserInput): User
  }
`;

const users = [];

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves books from the "books" array above.
const resolvers = {
  Query: {
    users: () => users,
  },
  Mutation: {
    addUser: async (_, { user }) => {
      user.userId = uuidv4();
      users.push(user);
      return user;
    },
  },
  User: {
    __resolveReference(user) {
      return fetchUserById(user.userId)
    }
  }
};

const fetchUserById = userId => users.find(user => userId == user.userId);

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }])
});

const port = process.env.PORT || 4003

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
