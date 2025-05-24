const mongoose = require('mongoose')

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
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
})

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

module.exports = mongoose.model('Book', bookSchema)
