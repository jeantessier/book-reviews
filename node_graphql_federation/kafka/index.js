const { Kafka } = require('kafkajs')
const { v4: uuidv4 } = require('uuid')

const {
    KAFKA_BOOTSTRAP_SERVER: bootstrapServer,
    KAFKA_CLIENT_ID: clientId,
    KAFKA_USERNAME: username,
    KAFKA_PASSWORD: password,
} = process.env
const sasl = username && password ? {
    username,
    password,
    mechanism: 'plain'
} : null
const ssl = !!sasl

const groupId = process.env.KAFKA_CONSUMER_GROUP_ID || uuidv4()

console.log('Kafka configuration:')
console.log(`    clientId: ${clientId}`)
console.log(`    bootstrapServer: ${bootstrapServer}`)
console.log(`    ssl: ${ssl}`)
console.log(`    sasl: ${sasl}`)

// This creates a client instance that is configured to connect to the Kafka broker provided by
// the environment variable KAFKA_BOOTSTRAP_SERVER
const kafka = new Kafka({
    clientId: clientId || '',
    brokers: [ bootstrapServer ],
    ssl,
    sasl
})

const sendMessage = async (topic, message, headers) => {
    const key = message.id
    const value = JSON.stringify(message)

    console.log('Sending message ...')
    console.log(`    topic: ${topic}`)
    console.log(`    headers: ${JSON.stringify(headers)}`)
    console.log(`    key: ${key}`)
    console.log(`    value: ${value}`)

    const producer = kafka.producer()
    await producer.connect()
    await producer.send({
        topic,
        messages: [
            { key, value, headers },
        ],
    })
    await producer.disconnect()
}

const startConsumer = async ({ groupId, topic, messageHandlers, defaultHandler, postCallback }) => {
    defaultHandler = defaultHandler ? defaultHandler : (type, key, body, headers) => console.log(`Skipping...`)
    postCallback = postCallback ? postCallback : () => {}

    const consumer = kafka.consumer({ groupId })
    await consumer.connect()
    await consumer.subscribe({ topic, fromBeginning: true })
    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            console.log(`====================   ${new Date().toJSON()}   ${message.headers["request_id"]}   ====================`)
            console.log("Received message!")
            console.log(`    topic: ${topic}`)
            console.log(`    partition: ${partition}`)
            console.log(`    offset: ${message.offset}`)
            const headers = ["current_user", "request_id"].reduce(
                (map, headerName) => {
                    if (message.headers[headerName]) {
                        map[headerName] = message.headers[headerName].toString()
                    }
                    return map
                },
                new Map()
            )
            console.log(`    headers: ${JSON.stringify(headers)}`)
            const key = message.key?.toString()
            console.log(`    key: ${key}`)
            const { type, ...body } = JSON.parse(message.value.toString())
            console.log(`    ${type} ${JSON.stringify(body)}`)
            if (type in messageHandlers) {
                messageHandlers[type](key, body, headers)
            } else {
                defaultHandler(type, key, body, headers)
            }
            postCallback()
        }
    })
}

module.exports = { groupId, kafka, sendMessage, startConsumer }
