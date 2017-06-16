var mongoose = require('mongoose');
var ObjectId = mongoose.Schema.Types.ObjectId;

var reviewSchema = new mongoose.Schema({
    book: {
        type: ObjectId,
        required: true
    },
    reviewer: {
        type: ObjectId,
        required: true
    },
    body: {
        type: String,
        required: true
    },
    start: Date,
    stop: Date
});

mongoose.model('Review', reviewSchema);
