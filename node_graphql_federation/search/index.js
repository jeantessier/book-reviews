const { ApolloServer, gql } = require('apollo-server');
const { buildFederatedSchema } = require('@apollo/federation');

require('dotenv').config();

const { groupId, sendMessage, startConsumer } = require('./kafka');

const indices = new Map();
const dump = map => map.forEach((index, word) => {
  console.log(`        ${word}:`)
  index.forEach((object, id) => {
    console.log(`          ${id}: ${JSON.stringify(object)}`)
  })
});

const topicName = /book-reviews.(books|reviews|users)/;
startConsumer(
    groupId,
    topicName,
    async ({ topic, partition, message }) => {
      console.log(`====================   ${new Date().toJSON()}   ====================`);
      console.log("Received message!");
      console.log(`    topic: ${topic}`);
      console.log(`    partition: ${partition}`);
      console.log(`    offset: ${message.offset}`);
      const key = message.key?.toString();
      console.log(`    key: ${key}`);
      const { type, ...body } = JSON.parse(message.value.toString())
      console.log(`    ${type} ${JSON.stringify(body)}`);
      switch (type) {
          case 'addBook':
              indexBook(body);
              break;
          case 'removeBook':
              scrubIndices('Book', key);
              break;
          case 'addReview':
              indexReview(body);
              break;
          case 'removeReview':
              scrubIndices('Review', key);
              break;
          case 'addUser':
              indexUser(body);
              break;
          case 'removeUser':
              scrubIndices('User', key);
              break;
          default:
              console.log("Skipping...");
              break;
      }
      console.log("    indices:");
      dump(indices);
    }
).then(() => {
  console.log(`Listening for "${topicName}" messages as consumer group ${groupId}.`)
})

const indexBook = book => {
  const indexEntry = {
    id: book.id,
    __typename: 'Book',
  };
  // indexWords(book.name.replaceAll('_', ' '), indexEntry);
  book.titles.forEach(title => indexWords(normalize(title.title), indexEntry))
  book.authors.forEach(author => indexWords(normalize(author), indexEntry))
  indexWords(normalize(book.publisher), indexEntry);
  book.years.forEach(year => indexWords(year, indexEntry))
}

const indexReview = review => {
  const indexEntry = {
    id: review.id,
    __typename: 'Review',
  };
  indexWords(normalize(review.body), indexEntry);
}

const indexUser = user => {
    const indexEntry = {
        id: user.id,
        __typename: 'User',
    };
    indexWords(normalize(user.name), indexEntry);
    indexWords(user.email, indexEntry);
}

const indexWords = (words, indexEntry) => {
  words.toLowerCase().split(/\s+/).forEach(word => indexWord(word, indexEntry));
};

const indexWord = (word, indexEntry) => {
    if (!(indices.has(word))) {
        console.log(`Creating index for "${word}"`);
        indices.set(word, new Map());
    }
    if (!(indices.get(word).has(indexEntry.id))) {
        console.log(`Creating index entry for ${indexEntry.id} under "${word}"`);
        indices.get(word).set(indexEntry.id, indexEntry);
    }
};

const scrubIndices = (typename, id) => {
    indices.forEach((index, word) => {
        if (index.get(id)?.__typename === typename) {
            console.log(`Removing index entry for ${id} under "${word}"`);
            index.delete(id);
        }
        if (indices.get(word).size === 0) {
            console.log(`Removing empty index for "${word}"`);
            indices.delete(word);
        }
    })
}

const normalize = text => text.replace(/[!?.&]/g, '');

// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.
const typeDefs = gql`
  extend type Book @key(fields: "id") {
    id: ID! @external
  }

  extend type Review @key(fields: "id") {
    id: ID! @external
  }

  extend type User @key(fields: "id") {
    id: ID! @external
  }

  union SearchResult = Book | Review | User

  type Query {
    search(q: String): [SearchResult!]!
  }
`;

const search = async (_, { q }) => {
  const resultsCollector = new Map();

  q.toLowerCase().split(/\s+/).forEach(word => {
      const weightIncrement = word.length;
      if (indices.has(word)) {
          indices.get(word).forEach((match, id) => {
              if (resultsCollector.has(id)) {
                  resultsCollector.get(id).weight += weightIncrement;
              } else {
                  resultsCollector.set(id, { weight: weightIncrement, ...match })
              }
          })
      }
  });

  const results = [...resultsCollector].map(([_, match]) => match).sort((match1, match2) => match2.weight - match1.weight);

  sendMessage(
      'book-reviews.searches',
      {
        query: q,
        results,
      }
  );

  return results;
};

// Resolvers define the technique for fetching the types defined in the
// schema. This resolver retrieves search results from the "indices"
// structure above.
const resolvers = {
  Query: {
    search,
  },
};

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
        console.log("    indices:");
        dump(indices);
      },
    },
  ],
});

const port = process.env.PORT || 4004

// The `listen` method launches a web server.
server.listen(port).then(({ url }) => {
  console.log(`🚀  Server ready at ${url}`);
});
