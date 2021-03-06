const mongoose = require('mongoose');
const Book = mongoose.model('Book');

const sendJSONresponse = (res, status, content) => {
    res.status(status);
    res.json(content);
};

module.exports.list = async (req, res) => {
    try {
        const books = await Book.find();
        sendJSONresponse(res, 200, books);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.create = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    const { name, titles, authors, publisher, years } = req.body;

    if (!name) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const namedBook = await Book.findOne({ name });
        if (namedBook) {
            sendJSONresponse(res, 409, {
                "message": `There is already a book named ${name}`
            });
            return;
        }

        const book = new Book({
            name,
            titles: titles ? titles : [],
            authors: authors ? authors : [],
            publisher,
            years: years ? years : [],
        });

        await book.save();
        sendJSONresponse(res, 201, book);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.readOne = async (req, res) => {
    try {
        const book = await Book.findOne({ _id: req.params.id });
        if (book) {
            sendJSONresponse(res, 200, book);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No book with ID ${req.params.id}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.updateOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        const book = await Book.findOne({ _id: req.params.id })
        if (!book) {
            sendJSONresponse(res, 404, {
                "message": `No book with ID ${req.params.id}`
            });
            return;
        }

        const { name, titles, authors, publisher, years } = req.body;

        const namedBook = await Book.findOne({ name });
        if (namedBook && namedBook != book) {
            sendJSONresponse(res, 409, {
                "message": `There is already a book named ${name}`
            });
            return;
        }

        if (name) {
            book.name = name;
        }
        if (titles) {
            book.titles = titles;
        }
        if (authors) {
            book.authors = authors;
        }
        if (publisher) {
            book.publisher = publisher;
        }
        if (years) {
            book.years = years;
        }

        await book.save()
        sendJSONresponse(res, 200, book);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.replaceOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    const { name, titles, authors, publisher, years } = req.body;

    if (!name) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const book = await Book.findOne({ _id: req.params.id });
        if (!book) {
            sendJSONresponse(res, 404, {
                "message": `No book with ID ${req.params.id}`
            });
            return;
        }

        const namedBook = await Book.findOne({ name });
        if (namedBook && namedBook != book) {
            sendJSONresponse(res, 409, {
                "message": `There is already a book named ${name}`
            });
            return;
        }

        book.name = name;
        book.titles = titles ? titles : [];
        book.authors = authors ? authors : [];
        book.publisher = publisher;
        book.years = years ? years : [];

        await book.save();
        sendJSONresponse(res, 200, book);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.deleteOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        const book = await Book.findOneAndDelete({ _id: req.params.id });
        if (book) {
            sendJSONresponse(res, 204, null);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No book with ID ${req.params.id}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.deleteAll = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        await Book.deleteMany();
        sendJSONresponse(res, 204, null);
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};
