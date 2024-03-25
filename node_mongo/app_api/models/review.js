const mongoose = require('mongoose')
const timestamps = require('mongoose-timestamp')

const reviewSchema = new mongoose.Schema({
    book: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Book',
        required: true,
    },
    reviewer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    body: {
        type: String,
        required: true,
    },
    start: Date,
    stop: Date,
})
reviewSchema.plugin(timestamps)

mongoose.model('Review', reviewSchema)
