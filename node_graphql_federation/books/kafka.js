const { Kafka } = require('kafkajs')

const {
  KAFKA_BOOTSTRAP_SERVER: bootstrapServer,
  KAFKA_USERNAME: username,
  KAFKA_PASSWORD: password,
} = process.env
const sasl = username && password ? { username, password, mechanism: 'plain' } : null
const ssl = !!sasl

// This creates a client instance that is configured to connect to the Kafka broker provided by
// the environment variable KAFKA_BOOTSTRAP_SERVER
const kafka = new Kafka({
  clientId: '',
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

module.exports = { kafka, sendMessage }
