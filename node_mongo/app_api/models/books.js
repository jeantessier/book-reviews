var mongoose = require('mongoose');
var ObjectId = mongoose.Schema.Types.ObjectId;

var titleSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    link: String
});

var bookSchema = new mongoose.Schema({
    name: {
        type: String,
        unique: true,
        required: true
    },
    titles: [titleSchema],
    authors: [String],
    publisher: String,
    years: [String],
    reviews: [ObjectId]
});

mongoose.model('Book', bookSchema);
