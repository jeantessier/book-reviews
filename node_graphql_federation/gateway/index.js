const { ApolloServer } = require('apollo-server')
const { ApolloGateway, IntrospectAndCompose, RemoteGraphQLDataSource } = require("@apollo/gateway")

require('dotenv').config()

const books_service = process.env.BOOKS_SERVICE || 'http://localhost:4001'
const reviews_service = process.env.REVIEWS_SERVICE || 'http://localhost:4002'
const users_service = process.env.USERS_SERVICE || 'http://localhost:4003'
const search_service = process.env.SEARCH_SERVICE || 'http://localhost:4004'
const signatures_service = process.env.SIGNATURES_SERVICE || 'http://localhost:4005'
const jwts_service = process.env.JWTS_SERVICE || 'http://localhost:4006'

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
    buildService: ({ url, name }) => {
        return new(class extends RemoteGraphQLDataSource {
            willSendRequest({ request, context }) {
                if (context.authHeader) {
                    request.http.headers.set('Authorization', context.authHeader)
                }
            }
        })({ url, name })
    }
})

// Pass the ApolloGateway to the ApolloServer constructor
const server = new ApolloServer({
    gateway,

    // Disable subscriptions (not currently supported with ApolloGateway)
    subscriptions: false,
    context: ({ req }) => {
        const authHeader = req.headers.authorization || ''
        if (!authHeader) return {}

        return { authHeader }
    },
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ====================`)
                console.log("Request did start!")
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
            },
        },
    ],
})

const port = process.env.PORT || 4000

server.listen(port).then(({ url }) => {
    console.log(`🚀 Server ready at ${url}`)
})
