require('dotenv').config()

require ('./open-telemetry')

const { ApolloServer } = require('@apollo/server')
const { startStandaloneServer } = require('@apollo/server/standalone')
const { buildSubgraphSchema } = require('@apollo/subgraph')
const { GraphQLError } = require('graphql')
const { gql } = require('graphql-tag')
const { v4: uuidv4 } = require('uuid')
const jwt = require('jsonwebtoken')

const { groupId, sendMessage, startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

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
  # The following directive migrates the schema to Federation 2.
  # I couldn't get @link to work, so I'm staying with Federation 1 for now.
  # extend schema @link(url: "https://specs.apollo.dev/federation/v2.0", import: ["@key", "@shareable"])

  type User @key(fields: "id") {
    id: ID!
    name: String!
    email: String!
    roles: [String!]!
  }

  input SignUpInput {
    name: String!
    email: String!
    password: String!
  }
  
  input AddUserInput {
    name: String!
    email: String!
    password: String!
    roles: [String!]!
  }

  input UpdateUserInput {
    id: ID!
    name: String
    email: String
    password: String
    roles: [String!]
  }

  type Query {
    me: User
    users: [User!]!
    user(id: ID!): User
  }

  type Mutation {
    signUp(user: SignUpInput): User
    addUser(user: AddUserInput): User
    updateUser(update: UpdateUserInput): User
    removeUser(id: ID!): Boolean!
  }
`

const signUp = async (_, { user }, context) => {
    const userForEmail = fetchUserByEmail(user.email)
    if (userForEmail) {
        throw new GraphQLError(`Email "${user.email}" is already taken.`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    user.id = uuidv4()
    user.roles = [ "ROLE_USER" ]

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userAdded',
            ...user,
        },
        headers,
    )

    return user
}

const addUser = async (_, { user }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (!context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation`)
    }

    const userForEmail = fetchUserByEmail(user.email)
    if (userForEmail) {
        throw new GraphQLError(`Email "${user.email}" is already taken.`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    user.id = uuidv4()

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userAdded',
            ...user,
        },
        headers,
    )

    return user
}

const updateUser = async (_, { update }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (update.id !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on another user.`)
    }
    if (update.roles && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to change roles on a user.`)
    }

    const user = fetchUserById(update.id)
    if (!user) {
        throw new GraphQLError(`No user with ID "${update.id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    if (update.email) {
        const userForEmail = fetchUserByEmail(update.email)
        if (userForEmail && userForEmail.id !== user.id) {
            throw new GraphQLError(`Email "${update.email}" is already taken.`, {
                extensions: {
                    code: 'BAD_USER_INPUT',
                }
            })
        }
    }

    const userUpdatedMessage = {
        ...user,
        ...update,
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userUpdated',
            ...userUpdatedMessage,
        },
        headers,
    )

    return userUpdatedMessage
}

const removeUser = async (_, { id }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (id !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on another user.`)
    }

    const user = fetchUserById(id)
    if (!user) {
        throw new GraphQLError(`No user with ID "${id}".`, {
            extensions: {
                code: 'BAD_USER_INPUT',
            }
        })
    }

    let headers = { request_id: context.requestId }
    if (context.currentUser) {
        headers["current_user"] = context.currentUser.id
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userRemoved',
            id,
        },
        headers,
    )

    return true
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves users from the "users" array above.
const resolvers = {
    Query: {
        me: async (_, {}, context) => {
            const user = fetchUserById(context.currentUser?.id)

            let headers = { request_id: context.requestId }
            if (context.currentUser) {
                headers["current_user"] = context.currentUser.id
            }

            await sendMessage(
                'book-reviews.views',
                {
                    __typename: 'User',
                    id: context.currentUser?.id,
                },
                headers,
            )

            return user
        },
        users: async () => users.values(),
        user: async (_, { id }, context) => {
            const user = fetchUserById(id)

            let headers = { request_id: context.requestId }
            if (context.currentUser) {
                headers["current_user"] = context.currentUser.id
            }

            await sendMessage(
                'book-reviews.views',
                {
                    __typename: 'User',
                    id: id,
                },
                headers,
            )

            return user
        },
    },
    Mutation: {
        signUp,
        addUser,
        updateUser,
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

const port = process.env.PORT || 4003

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
