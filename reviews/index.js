const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type Review @key(fields: "id") {
    id: ID!
    reviewer: User!
    book: Book!
    body: String!
    start: String
    stop: String
  }

  input ReviewInput {
      reviewerId: ID!
      bookId: ID!
      body: String!
      start: String
      stop: String
  }

  extend type User @key(fields: "id") {
    id: ID! @external
    reviews: [Review!]!
  }

  extend type Book @key(fields: "id") {
    id: ID! @external
    reviews: [Review!]!
  }

  type Query {
    reviews: [Review!]!
    review(id: ID!): Review
  }

  type Mutation {
    addReview(review: ReviewInput): Review
  }
`;

const reviews = [];

const addReview = async (_, { review }) => {
  review.id = uuidv4();
  review.reviewer = { id: review.reviewerId };
  review.book = { id: review.bookId };
  reviews.push(review);
  return review;
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
  Query: {
    reviews: async () => reviews,
    review: async (_, { id }) => fetchReviewById(id),
  },
  Mutation: {
    addReview
  },
  Review: {
    __resolveReference(review) {
      return fetchReviewById(review.id)
    }
  },
  review: {
    __resolveReference(review) {
      return fetchReviewById(review.id)
    }
  },
  Book: {
    reviews(book) {
      return fetchReviewsByBookId(book.id);
    }
  },
  User: {
    reviews(user) {
      return fetchReviewsByReviewerId(user.id);
    }
  },
};

const fetchReviewById = id => reviews.find(review => id === review.id);
const fetchReviewsByBookId = id => reviews.filter(review => id === review.book.id);
const fetchReviewsByReviewerId = id => reviews.filter(review => id === review.reviewer.id);

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }]),
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log(`====================   ${new Date().toJSON()}   ====================`);
        console.log("Request did start!");
        console.log(`    query: ${requestContext.request.query}`);
        console.log(`    operationName: ${requestContext.request.operationName}`);
        console.log(`    variables: ${JSON.stringify(requestContext.request.variables)}`);
        console.log(`    reviews: ${JSON.stringify(reviews)}`);
      },
    },
  ],
});

const port = process.env.PORT || 4002

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
