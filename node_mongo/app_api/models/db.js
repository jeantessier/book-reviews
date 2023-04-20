const mongoose = require('mongoose')

const dbURI = process.env.MONGODB_URI
mongoose.connect(dbURI, { useNewUrlParser: true, useUnifiedTopology: true })

mongoose.connection.on("connected", () => {
    console.log("Mongoose connected to " + dbURI)
})

mongoose.connection.on("error", err => {
    console.log("Mongoose connection error: " + err)
})

mongoose.connection.on("disconnected", () => {
    console.log("Mongoose disconnected")
})

// CAPTURE APP TERMINATION / RESTART EVENTS
// To be called when process is restarted or terminated
const gracefulShutdown = (msg, callback) => {
    mongoose.connection.close()
        .then(() => {
            console.log(`Mongoose disconnected through ${msg}`)
            callback()
        })
}
// For nodemon restarts
process.once('SIGUSR2', () => {
    gracefulShutdown('nodemon restart', () => {
        process.kill(process.pid, 'SIGUSR2')
    })
})
// For app termination
process.on('SIGINT', () => {
    gracefulShutdown('app termination', () => {
        process.exit(0)
    })
})

// BRING IN YOUR SCHEMAS & MODELS
require('./user')
require('./book')
require('./review')
