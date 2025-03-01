require('dotenv').config()

require ('./open-telemetry')

const { MongoDBAtlasVectorSearch } = require('@langchain/mongodb')
const { OpenAIEmbeddings } = require('@langchain/openai')
const { GoogleGenerativeAIEmbeddings } = require('@langchain/google-genai')
const { MongoClient } = require('mongodb')

const { startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const groupId = 'vector_indexer'
const topicName = /book-reviews.(books|reviews|users)/
startConsumer({
    groupId,
    topic: topicName,
    messageHandlers: {
        bookAdded: (_, book) => indexBook(book),
        bookUpdated: (_, book) => indexBook(book),
        bookRemoved: key => scrubIndices(`Book-${key}`),
        reviewAdded: (_, review) => indexReview(review),
        reviewUpdated: (_, review) => indexReview(review),
        reviewRemoved: key => scrubIndices(`Review-${key}`),
        userAdded: (_, user) => indexUser(user),
        userUpdated: (_, user) => indexUser(user),
        userRemoved: key => scrubIndices(`User-${key}`),
    },
}).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

const client = new MongoClient(process.env.MONGODB_ATLAS_URI || "")
const collection = client
    .db(process.env.MONGODB_ATLAS_DB_NAME)
    .collection(process.env.MONGODB_ATLAS_COLLECTION_NAME)

// const embeddings = new OpenAIEmbeddings({
//     model: "text-embedding-3-small",
// })

const embeddings = new GoogleGenerativeAIEmbeddings({
    apiKey: process.env.GOOGLE_API_KEY,
    model: "text-embedding-004",
})

const vectorStore = new MongoDBAtlasVectorSearch(embeddings, {
    collection,
    indexName: 'vector_index', // The name of the Atlas search index. Defaults to "default"
    textKey: 'text', // The name of the collection field containing the raw content. Defaults to "text"
    embeddingKey: 'embedding', // The name of the collection field containing the embedded text. Defaults to "embedding"
})

const indexBook = book => {
    const pageContent = [
        book.titles.map(title => title.title),
        `Written by ${book.authors.join(', ')}`,
        `Published by ${book.publisher}.`,
        `Published in ${book.years.join(', ')}.`,
    ].flat()
    updateIndex(
        book,
        pageContent.join('\n'),
        {
            id: `Book-${book.id}`,
            type: 'Book',
        }
    )
}

const indexReview = review => {
    const pageContent = [
        review.body,
    ]
    if (review.start) {
        pageContent.push(`Started reading on ${review.start}.`)
    }
    if (review.stop) {
        pageContent.push(`Finished reading on ${review.stop}.`)
    }
    updateIndex(
        review,
        pageContent.join('\n'),
        {
            id: `Review-${review.id}`,
            type: 'Review',
        }
    )
}

const indexUser = user => {
    const pageContent = `${user.name} <${user.email}>`
    updateIndex(
        user,
        pageContent,
        {
            id: `User-${user.id}`,
            type: 'User',
        }
    )
}

const scrubIndices = async id => {
    if (process.env.DEBUG) {
        console.log(`Removing entity ${id}`)
    }

    await vectorStore.delete({ ids: [id] })
        .then(() => console.log(`Deleted entity ${id}`))
        .catch(err => console.error(`Could not delete entity ${id}: ${err}`))
}

const updateIndex = async (entity, pageContent, metadata) => {
    const document = {
        ... entity,
        pageContent,
        metadata,
    }

    if (process.env.DEBUG) {
        console.log(`Adding ${metadata.type} entity ${metadata.id}`)
    }

    await vectorStore.addDocuments([ document ], { ids: [ metadata.id ] })
        .then(() => console.log(`Added ${metadata.type} entity ${metadata.id}`))
        .catch(err => console.error(`Could not add ${metadata.type} entity ${metadata.id}: ${err}`))
}
