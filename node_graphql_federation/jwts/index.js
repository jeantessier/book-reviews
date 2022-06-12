const { ApolloServer, gql } = require('apollo-server')
const { UserInputError } = require('apollo-server-errors')
const { buildSubgraphSchema } = require('@apollo/federation')
const jwt = require('jsonwebtoken');

require('dotenv').config()

const { groupId, startConsumer } = require('./kafka')

const users = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const topicName = 'book-reviews.users'
startConsumer(
    groupId,
    topicName,
    {
        userAdded: (key, user) => users.set(key, user),
        userUpdated: (key, user) => users.set(key, user),
        userRemoved: key => users.delete(key),
    },
    () => {
        if (process.env.DEBUG) {
            console.log("    users:")
            dump(users)
        }
    }
).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
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
        throw new UserInputError(`No user with email "${input.email}".`)
    }

    if (input.password !== user.password) {
        throw new UserInputError(`Password for ${input.email} does not match.`)
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

const fetchUserByEmail = email => {
    const userEntry = Array.from(users.entries()).find(([_, user]) => user.email === email)
    return userEntry ? userEntry[1] : undefined
}

const server = new ApolloServer({
    schema: buildSubgraphSchema([ { typeDefs, resolvers } ]),
    plugins: [
        {
            requestDidStart(requestContext) {
                console.log(`====================   ${new Date().toJSON()}   ====================`)
                console.log("Request did start!")
                console.log(`    query: ${requestContext.request.query}`)
                console.log(`    operationName: ${requestContext.request.operationName}`)
                console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`)
                if (process.env.DEBUG) {
                    console.log("    users:")
                    dump(users)
                }
            },
        },
    ],
})

const port = process.env.PORT || 4006

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
