const mongoose = require('mongoose');
const ObjectId = mongoose.Schema.Types.ObjectId;

const titleSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    link: String
});

const bookSchema = new mongoose.Schema({
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
