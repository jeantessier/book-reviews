const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { gql } = require('graphql-tag')

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

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
    schema: buildSubgraphSchema({ typeDefs, resolvers }),
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ====================`)
                console.log("Request did start!")
                if (process.env.DEBUG) {
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

const port = process.env.PORT || 4005

// The `listen` method launches a web server.
startStandaloneServer(server, {
    listen: { port },
}).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
