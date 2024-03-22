const mongoose = require('mongoose')
const timestamps = require('mongoose-timestamp')
const ObjectId = mongoose.Schema.Types.ObjectId

const reviewSchema = new mongoose.Schema({
    book: {
        type: ObjectId,
        ref: 'Book',
        required: true,
    },
    reviewer: {
        type: ObjectId,
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
