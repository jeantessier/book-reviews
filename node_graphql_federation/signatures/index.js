const { ApolloServer, gql } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')
const jwt = require('jsonwebtoken');

require('dotenv').config()

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  extend type User @key(fields: "id") {
    id: ID! @external
    name: String! @external
    email: String! @external
    
    """
    an elegant custom signature
    """
    signature: String! @requires(fields: "name email")
  }
`

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
    User: {
        signature: async user => `-- ${user.name} <${user.email}>`,
    },
}

const server = new ApolloServer({
    schema: buildFederatedSchema([ { typeDefs, resolvers } ]),
    context: ({ req }) => {
        const authHeader = req.headers.authorization || ''
        if (!authHeader) return {}

        const authHeaderParts = authHeader.split(' ')
        if (authHeaderParts.length < 2 || authHeaderParts[0].toLowerCase() !== 'bearer') return {}

        const jwtPayload = jwt.verify(authHeaderParts[1], process.env.JWT_SECRET)

        return jwtPayload
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

const port = process.env.PORT || 4005

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
