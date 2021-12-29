const mongoose = require('mongoose')
const timestamps = require('mongoose-timestamp')

const titleSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
    },
    link: String,
})

const bookSchema = new mongoose.Schema({
    name: {
        type: String,
        unique: true,
        required: true,
    },
    titles: [titleSchema],
    authors: [String],
    publisher: String,
    years: [String],
})
bookSchema.plugin(timestamps)

mongoose.model('Book', bookSchema)
