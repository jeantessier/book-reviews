const { ApolloServer, gql } = require('apollo-server')
const { AuthenticationError, ForbiddenError, UserInputError } = require('apollo-server-errors')
const { buildFederatedSchema } = require('@apollo/federation')
const { v4: uuidv4 } = require('uuid')
const jwt = require('jsonwebtoken');

require('dotenv').config()

const { groupId, sendMessage, startConsumer } = require('./kafka')

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

const signUp = async (_, { user }) => {
    const userForEmail = fetchUserByEmail(user.email)
    if (userForEmail) {
        throw new UserInputError(`Email "${user.email}" is already taken.`)
    }

    user.id = uuidv4()
    user.roles = [ "ROLE_USER" ]

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userAdded',
            ...user,
        }
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
        throw new UserInputError(`Email "${user.email}" is already taken.`)
    }

    user.id = uuidv4()

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userAdded',
            ...user,
        }
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
        throw new UserInputError(`No user with ID "${update.id}".`)
    }

    if (update.email) {
        const userForEmail = fetchUserByEmail(update.email)
        if (userForEmail && userForEmail.id !== user.id) {
            throw new UserInputError(`Email "${update.email}" is already taken.`)
        }
    }

    const userUpdatedMessage = {
        ...user,
        ...update,
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userUpdated',
            ...userUpdatedMessage,
        }
    )

    return userUpdatedMessage
}

const removeUser = async (_, { id }, context, info) => {
    if (!context.currentUser) {
        throw new AuthenticationError(`You need to be signed in to use the ${info.fieldName} mutation.`)
    }
    if (update.id !== context.currentUser.id && !context.currentUser.roles?.includes('ROLE_ADMIN')) {
        throw new ForbiddenError(`You need to have admin privileges to use the ${info.fieldName} mutation on another user.`)
    }

    const user = fetchUserById(id)
    if (!user) {
        throw new UserInputError(`No user with ID "${id}".`)
    }

    await sendMessage(
        'book-reviews.users',
        {
            type: 'userRemoved',
            id,
        }
    )

    return true
}

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves users from the "users" array above.
const resolvers = {
    Query: {
        me: async (_, {}, context) => fetchUserById(context.currentUser?.id),
        users: async () => users.values(),
        user: async (_, { id }) => fetchUserById(id),
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
const fetchUserByEmail = email => {
    const userEntry = Array.from(users.entries()).find(([_, user]) => user.email === email)
    return userEntry ? userEntry[1] : undefined
}

const server = new ApolloServer({
    schema: buildFederatedSchema([ { typeDefs, resolvers } ]),
    context: ({ req }) => {
        try {
            const authHeader = req.headers.authorization || ''
            if (!authHeader) return {}

            const authHeaderParts = authHeader.split(' ')
            if (authHeaderParts.length < 2 || authHeaderParts[0].toLowerCase() !== 'bearer') return {}

            const jwtPayload = jwt.verify(authHeaderParts[1], process.env.JWT_SECRET)

            return { currentUser: { id: jwtPayload.sub, ...jwtPayload } }
        } catch (e) {
            console.warn(e)
            return {}
        }
    },
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

const port = process.env.PORT || 4003

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
    console.log(`🚀  Server ready at ${url}`)
})
