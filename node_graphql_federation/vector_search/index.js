require('dotenv').config()

require ('./open-telemetry')

const { MongoDBAtlasVectorSearch } = require('@langchain/mongodb')
const { OpenAIEmbeddings } = require('@langchain/openai')
const { MongoClient } = require('mongodb')

const { startConsumer } = require('@jeantessier/book_reviews.node_graphql_federation.kafka')

const groupId = 'vector_search'
const topicName = 'book-reviews.searches'
startConsumer({
    groupId,
    topic: topicName,
    messageHandlers: {},
    defaultHandler: (type, key, { query, results }) => {
        console.log(`Replaying "${query}" and comparing to ${results.length} result(s) ...`)
        replaySearch(query, results)
    },
}).then(() => {
    console.log(`Listening for "${topicName}" messages as consumer group "${groupId}".`)
})

const client = new MongoClient(process.env.MONGODB_ATLAS_URI || "")
const collection = client
    .db(process.env.MONGODB_ATLAS_DB_NAME)
    .collection(process.env.MONGODB_ATLAS_COLLECTION_NAME)

const embeddings = new OpenAIEmbeddings({
    model: "text-embedding-3-small",
})

const vectorStore = new MongoDBAtlasVectorSearch(embeddings, {
    collection,
    indexName: 'vector_index', // The name of the Atlas search index. Defaults to "default"
    textKey: 'text', // The name of the collection field containing the raw content. Defaults to "text"
    embeddingKey: 'embedding', // The name of the collection field containing the embedded text. Defaults to "embedding"
})

const replaySearch = async (query, expectedResults) => {
    // Number of nearest neighbors to return.
    const k = 2

    const similaritySearchResults = await vectorStore.similaritySearch(query, k)

    console.log(`Expected ${expectedResults.length} result(s)`)
    console.log('--------')
    expectedResults.forEach(result => console.log(`* ${JSON.stringify(result)}`))
    console.log('')
    console.log(`Actually got ${similaritySearchResults.length} result(s)`)
    console.log('--------')
    similaritySearchResults.forEach(doc => console.log(`* ${doc.pageContent} [${JSON.stringify(doc.metadata)}]`))
}
