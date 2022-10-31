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

const groupId = process.env.KAFKA_CONSUMER_GROUP_ID ? process.env.KAFKA_CONSUMER_GROUP_ID : uuidv4()

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

const sendMessage = async (topic, message) => {
    const key = message.id
    const value = JSON.stringify(message)

    console.log('Sending message ...')
    console.log(`    topic: ${topic}`)
    console.log(`    key: ${key}`)
    console.log(`    value: ${value}`)

    const producer = kafka.producer()
    await producer.connect()
    await producer.send({
        topic,
        messages: [
            { key, value },
        ],
    })
    await producer.disconnect()
}

const startConsumer = async (groupId, topic, messageHandlers, postCallback = () => {}) => {
    const consumer = kafka.consumer({ groupId })
    await consumer.connect()
    await consumer.subscribe({ topic, fromBeginning: true })
    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            console.log(`====================   ${new Date().toJSON()}   ====================`)
            console.log("Received message!")
            console.log(`    topic: ${topic}`)
            console.log(`    partition: ${partition}`)
            console.log(`    offset: ${message.offset}`)
            const key = message.key?.toString()
            console.log(`    key: ${key}`)
            const { type, ...body } = JSON.parse(message.value.toString())
            console.log(`    ${type} ${JSON.stringify(body)}`)
            if (type in messageHandlers) {
                messageHandlers[type](key, body)
            } else {
                console.log("Skipping...")
            }
            postCallback()
        }
    })
}

module.exports = { groupId, kafka, sendMessage, startConsumer }
