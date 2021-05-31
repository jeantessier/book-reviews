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
    a signed JWT for this user
    """
    jwt: String! @requires(fields: "name email")
  }
`

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
    User: {
        jwt: async user => generateJwt(user),
    },
}

const generateJwt = user => {
    const payload = {
        name: user.name,
        email: user.email
    }
    const options = {
        expiresIn: 3 * 24 * 60 *  60, // 3 days in seconds
        issuer: 'book-reviews',
        subject: user.id,
    };
    return jwt.sign(payload, process.env.JWT_SECRET, options)
}

const server = new ApolloServer({
    schema: buildFederatedSchema([ { typeDefs, resolvers } ]),
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

const port = process.env.PORT || 4006

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
