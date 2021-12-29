const mongoose = require('mongoose')
const timestamps = require('mongoose-timestamp')
const ObjectId = mongoose.Schema.Types.ObjectId

const reviewSchema = new mongoose.Schema({
    book: {
        type: ObjectId,
        required: true,
    },
    reviewer: {
        type: ObjectId,
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
