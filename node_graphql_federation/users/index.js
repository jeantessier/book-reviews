const { ApolloServer, gql } = require('apollo-server')
const { buildFederatedSchema } = require('@apollo/federation')
const { v4: uuidv4 } = require('uuid')

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('./kafka')

const users = new Map()
const dump = map => map.forEach((v, k) => console.log(`        ${k}: ${JSON.stringify(v)}`))

const topicName = 'book-reviews.users'
startConsumer(
    groupId,
    topicName,
    {
        addUser: (key, user) => users.set(key, user),
        removeUser: key => users.delete(key),
    },
    () => {
        console.log("    users:")
        dump(users)
    }
).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group ${groupId}.`)
})

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type User @key(fields: "id") {
    id: ID!
    name: String!
    email: String!
  }

  input UserInput {
    name: String!
    email: String!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
  }

  type Mutation {
    addUser(user: UserInput): User
    removeUser(id: ID!): Boolean!
  }
`

const addUser = async (_, { user }) => {
    user.id = uuidv4()

    await sendMessage(
        'book-reviews.users',
        {
            type: 'addUser',
            ...user,
        }
    )

    return user
}

const removeUser = async (_, { id }) => {
    const found = fetchUserById(id) !== undefined

    if (found) {
        await sendMessage(
            'book-reviews.users',
            {
                type: 'removeUser',
                id,
            }
        )
    }

    return found
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves users from the "users" array above.
const resolvers = {
    Query: {
        users: async () => users.values(),
        user: async (_, { id }) => fetchUserById(id),
    },
    Mutation: {
        addUser,
        removeUser,
    },
    User: {
        __resolveReference: async user => {
            return {
                ...user,
                ...fetchUserById(user.id),
            }
        }
    },
}

const fetchUserById = id => users.get(id)

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
                console.log("    users:")
                dump(users)
            },
        },
    ],
})

const port = process.env.PORT || 4003

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
