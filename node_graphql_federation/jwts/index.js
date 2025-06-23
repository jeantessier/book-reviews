const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { GraphQLError } = require('graphql')
const { gql } = require('graphql-tag')
const { v4: uuidv4 } = require("uuid")
const jwt = require('jsonwebtoken')

const { groupId, startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const users = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const topicName = 'book-reviews.users'
startConsumer({
    groupId,
    topic: topicName,
    messageHandlers: {
        userAdded: (key, user) => users.set(key, user),
        userUpdated: (key, user) => users.set(key, user),
        userRemoved: key => users.delete(key),
    },
    postCallback: () => {
        if (process.env.DEBUG) {
            console.log("    users:")
            dump(users)
        }
    },
}).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

  input LoginInput {
    email: String!
    password: String!
  }
  
  type LoginPayload {
    """
    a signed JWT for the user with matching email and password
    """
    jwt: String
  }
  
  type Mutation {
    login(input: LoginInput!): LoginPayload
  }
`

const login = async (_, { input }) => {
    const user = fetchUserByEmail(input.email)
    if (!user) {
        throw new GraphQLError(`No user with email "${input.email}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    if (input.password !== user.password) {
        throw new GraphQLError(`Password for ${input.email} does not match.`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    return { jwt: generateJwt(user) }
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
    Mutation: {
        login,
    },
}

const generateJwt = user => {
    const payload = {
        name: user.name,
        email: user.email,
        roles: user.roles,
    }
    const options = {
        expiresIn: 3 * 24 * 60 *  60, // 3 days in seconds
        issuer: 'book-reviews',
        subject: user.id,
    };
    return jwt.sign(payload, process.env.JWT_SECRET, options)
}

const fetchUserByEmail = email => Array.from(users.values()).find(user => user.email === email)

const server = new ApolloServer({
    schema: buildSubgraphSchema({ typeDefs, resolvers }),
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ${requestContext.contextValue.requestId}   ====================`)
                console.log("Request did start!")
                if (process.env.DEBUG) {
                    console.log(`    context: ${JSON.stringify(requestContext.contextValue)}`)
                }
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
                if (process.env.DEBUG) {
                    console.log("    users:")
                    dump(users)
                }
                console.log()
            },
        },
    ],
})

const getCurrentUser = (req) => {
    try {
        const authHeader = req.headers.authorization || ''
        if (!authHeader) return null

        const authHeaderParts = authHeader.split(' ')
        if (authHeaderParts.length < 2 || authHeaderParts[0].toLowerCase() !== 'bearer') return null

        const jwtPayload = jwt.verify(authHeaderParts[1], process.env.JWT_SECRET)

        return { id: jwtPayload.sub, ...jwtPayload }
    } catch (e) {
        console.warn(e)
        return null
    }
}

const port = process.env.PORT || 4006

// The `listen` method launches a web server.
startStandaloneServer(server, {
    context: ({ req }) => {
        return {
            currentUser: getCurrentUser(req),
            requestId: req.headers["x-request-id"] || uuidv4(),
        }
    },
    listen: { port },
}).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
