const { ApolloServer } = require('apollo-server')
const { ApolloGateway, RemoteGraphQLDataSource } = require("@apollo/gateway")

require('dotenv').config()

const books_service = process.env.BOOKS_SERVICE || 'http://localhost:3001/graphql'

const gateway = new ApolloGateway({
    serviceList: [
        { name: 'books', url: books_service },
    ],
    buildService: ({ url, name }) => {
        return new (class extends RemoteGraphQLDataSource {
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

const port = process.env.PORT || 3000

server.listen(port).then(({ url }) => {
    console.log(`🚀 Server ready at ${url}`)
})