const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type User @key(fields: "id") {
    id: ID!
    name: String!
    email: String!
  }

  input UserInput {
    name: String!
    email: String!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
  }

  type Mutation {
    addUser(user: UserInput): User
  }
`;

const users = [];

const addUser = async (_, { user }) => {
  user.id = uuidv4();
  users.push(user);
  return user;
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves users from the "users" array above.
const resolvers = {
  Query: {
    users: async () => users,
    user: async (_, { id }) => fetchUserById(id),
  },
  Mutation: {
    addUser,
  },
  User: {
    __resolveReference: async user => {
      return {
        ...user,
        ...fetchUserById(user.id),
      };
    }
  },
};

const fetchUserById = id => users.find(user => id === user.id);

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
        console.log(`    users: ${JSON.stringify(users)}`);
      },
    },
  ],
});

const port = process.env.PORT || 4003

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
