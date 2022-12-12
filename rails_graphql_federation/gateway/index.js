const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { ApolloGateway, IntrospectAndCompose, RemoteGraphQLDataSource } = require("@apollo/gateway")

require('dotenv').config()

const books_service = process.env.BOOKS_SERVICE || 'http://localhost:3001/graphql'
const reviews_service = process.env.REVIEWS_SERVICE || 'http://localhost:3002/graphql'
const users_service = process.env.USERS_SERVICE || 'http://localhost:3003/graphql'
const search_service = process.env.SEARCH_SERVICE || 'http://localhost:3004/graphql'
const signatures_service = process.env.SIGNATURES_SERVICE || 'http://localhost:3005/graphql'
const jwts_service = process.env.JWTS_SERVICE || 'http://localhost:3006/graphql'

class AuthenticatedDataSource extends RemoteGraphQLDataSource {
    willSendRequest({ request, context }) {
        if (context.authHeader) {
            request.http.headers.set('Authorization', context.authHeader)
        }
        if (process.env.DEBUG) {
            console.log("Will send request!")
            console.log(`    context: ${JSON.stringify(context)}`)
            console.log(`    request: ${JSON.stringify(request)}`)
            console.log()
        }
    }

    didReceiveResponse({ request, response, context }) {
        if (process.env.DEBUG) {
            console.log("Did receive response!")
            console.log(`    context: ${JSON.stringify(context)}`)
            console.log(`    request: ${JSON.stringify(request)}`)
            console.log(`    response: ${JSON.stringify(response)}`)
            console.log()
        }
        return response
    }
}

// See https://www.apollographql.com/docs/apollo-server/using-federation/apollo-gateway-setup/
// for why IntrospectAndCompose is not recommended for production systems.
const gateway = new ApolloGateway({
    supergraphSdl: new IntrospectAndCompose({
        subgraphs: [
            { name: 'books', url: books_service },
            { name: 'reviews', url: reviews_service },
            { name: 'users', url: users_service },
            { name: 'search', url: search_service },
            { name: 'signatures', url: signatures_service },
            { name: 'jwts', url: jwts_service },
        ],
    }),
    buildService: ({ name, url }) => {
        return new AuthenticatedDataSource({ url })
    }
})

// Pass the ApolloGateway to the ApolloServer constructor
const server = new ApolloServer({
    gateway,
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ====================`)
                console.log("Request did start!")
                if (process.env.DEBUG)  {
                    console.log(`    context: ${JSON.stringify(requestContext.contextValue)}`)
                }
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
                console.log()
            },
        },
    ],
})

const port = process.env.PORT || 3000

startStandaloneServer(server, {
    context: async ({ req }) => {
        const authHeader = req.headers.authorization || ''
        if (!authHeader) return {}

        return { authHeader }
    },
    listen: { port },
}).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
