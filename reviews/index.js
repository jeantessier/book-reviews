const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');
const uuidv4 = require('uuid/v4');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  type Review @key(fields: "reviewId") {
    reviewId: ID!
    user: User!
    book: Book!
    body: String!
    start: String
    stop: String
  }

  input ReviewInput {
      userId: ID!
      bookId: ID!
      body: String!
      start: String
      stop: String
  }

  extend type User @key(fields: "userId") {
    userId: ID! @external
    reviews: [Review!]!
  }

  extend type Book @key(fields: "bookId") {
    bookId: ID! @external
    reviews: [Review!]!
  }

  type Query {
    reviews: [Review!]!
  }

  type Mutation {
    addReview(review: ReviewInput): Review
  }
`;

const reviews = [];

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves reviews from the "reviews" array above.
const resolvers = {
  Query: {
    reviews: () => reviews,
  },
  Mutation: {
    addReview: async (_, { review }) => {
      review.reviewId = uuidv4();
      review.user = { userId: review.userId };
      review.book = { bookId: review.bookId };
      reviews.push(review);
      return review;
    },
  },
  review: {
    __resolveReference(review) {
      return fetchReviewById(review.reviewId)
    }
  }
};

const fetchReviewById = reviewId => reviews.find(review => reviewId == review.reviewId);

const server = new ApolloServer({
  schema: buildFederatedSchema([{ typeDefs, resolvers }])
});

const port = process.env.PORT || 4002

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
