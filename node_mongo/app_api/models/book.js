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
}, {
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
})
bookSchema.plugin(timestamps)

bookSchema.virtual('numReviews', {
    ref: 'Review',
    localField: '_id',
    foreignField: 'book',
    count: true,
})
bookSchema.virtual('reviews', {
    ref: 'Review',
    localField: '_id',
    foreignField: 'book',
})

mongoose.model('Book', bookSchema)
