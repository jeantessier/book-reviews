require('dotenv').config()

require ('./open-telemetry')

const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { ApolloGateway, IntrospectAndCompose, RemoteGraphQLDataSource } = require("@apollo/gateway")
const { v4: uuidv4 } = require('uuid')

const books_service = process.env.BOOKS_SERVICE || 'http://localhost:4001'
const reviews_service = process.env.REVIEWS_SERVICE || 'http://localhost:4002'
const users_service = process.env.USERS_SERVICE || 'http://localhost:4003'
const search_service = process.env.SEARCH_SERVICE || 'http://localhost:4004'
const signatures_service = process.env.SIGNATURES_SERVICE || 'http://localhost:4005'
const jwts_service = process.env.JWTS_SERVICE || 'http://localhost:4006'

class AuthenticatedDataSource extends RemoteGraphQLDataSource {
    willSendRequest({ request, context }) {
        request.http.headers.set('X-Request-Id', context.requestId)
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
                console.log(`====================   ${new Date().toJSON()}   ${requestContext.contextValue.requestId}   ====================`)
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

const port = process.env.PORT || 4000

startStandaloneServer(server, {
    context: async ({ req }) => {
        return {
            authHeader: req.headers.authorization || '',
            requestId: req.headers["x-request-id"] || uuidv4()
        }
    },
    listen: { port },
}).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
