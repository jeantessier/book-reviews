const { ApolloServer } = require('apollo-server');
const { ApolloGateway } = require("@apollo/gateway");

require('dotenv').config();

const books_service = process.env.BOOKS_SERVICE || 'http://localhost:4001'
const reviews_service = process.env.REVIEWS_SERVICE || 'http://localhost:4002'
const users_service = process.env.USERS_SERVICE || 'http://localhost:4003'
const search_service = process.env.SEARCH_SERVICE || 'http://localhost:4004'
const signatures_service = process.env.SIGNATURES_SERVICE || 'http://localhost:4005'

const gateway = new ApolloGateway({
  serviceList: [
    { name: 'books', url: books_service },
    { name: 'reviews', url: reviews_service },
    { name: 'users', url: users_service },
    { name: 'search', url: search_service },
    { name: 'signatures', url: signatures_service },
  ]
});

// Pass the ApolloGateway to the ApolloServer constructor
const server = new ApolloServer({
  gateway,

  // Disable subscriptions (not currently supported with ApolloGateway)
  subscriptions: false,
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log(`====================   ${new Date().toJSON()}   ====================`);
        console.log("Request did start!");
        console.log(`    query: ${requestContext.request.query}`);
        console.log(`    operationName: ${requestContext.request.operationName}`);
        console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`);
      },
    },
  ],
});

const port = process.env.PORT || 4000

server.listen(port).then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
