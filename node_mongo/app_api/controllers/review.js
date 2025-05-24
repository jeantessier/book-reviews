const Book = require("../models/book")
const Review = require("../models/review")
const User = require("../models/user")

const sendJSONresponse = (res, status, content) => res.status(status).json(content)

module.exports.list = (req, res) => {
    Review
        .find()
        .sort({ start: -1 })
        .then(reviews => sendJSONresponse(res, 200, reviews))
        .catch(err => sendJSONresponse(res, 400, err))
}

module.exports.create = async (req, res) => {
    const { book, body, start, stop } = req.body
    let { reviewer } = req.body

    if (reviewer) {
        if (reviewer !== req.currentUser.sub && !req.currentUser.admin) {
            sendJSONresponse(res, 403, { message: "You need admin privileges to create reviews on behalf of someone else" })
            return
        }
    } else {
        reviewer = req.currentUser.sub
    }

    if (!book || !body) {
        sendJSONresponse(res, 400, { message: "All fields required" })
        return
    }

    try {
        const [ actualReviewer, actualBook, actualReview ] = await Promise.all([
            User.findOne({ _id: reviewer }),
            Book.findOne({ _id: book }),
            Review.findOne({ reviewer, book }),
        ])

        if (!actualReviewer) {
            sendJSONresponse(res, 404, { message: `No user with ID ${reviewer}` })
            return
        }
        if (!actualBook) {
            sendJSONresponse(res, 404, { message: `No book with ID ${book}` })
            return
        }
        if (actualReview) {
            sendJSONresponse(res, 409, { message: `There is already a review of book ${book} by reviewer ${reviewer}` })
            return
        }

        const review = new Review({
            book,
            reviewer,
            body,
            start,
            stop,
        })

        await review.save()
        sendJSONresponse(res, 201, review)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.readOne = (req, res) => {
    Review
        .findById(req.params.id)
        .populate('book')
        .populate('reviewer')
        .then(review => {
            if (review) {
                sendJSONresponse(res, 200, review)
            } else {
                sendJSONresponse(res, 404, { message: `No review with ID ${req.params.id}` })
            }
        })
        .catch(err => sendJSONresponse(res, 404, err))
}

module.exports.updateOne = async (req, res) => {
    try {
        const review = await Review.findById(req.params.id)
        if (!review) {
            sendJSONresponse(res, 404, { message: `No review with ID ${req.params.id}` })
            return
        }
        if (review.reviewer.toString() !== req.currentUser.sub && !req.currentUser.admin) {
            sendJSONresponse(res, 403, { message: "You need admin privileges to edit someone else's review" })
            return
        }

        const { body, start, stop } = req.body

        if (body) {
            review.body = body
        }
        if (start) {
            review.start = Date.parse(start)
        }
        if (stop) {
            review.stop = Date.parse(stop)
        }

        await review.save()
        sendJSONresponse(res, 200, review)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.replaceOne = async (req, res) => {
    const { body, start, stop } = req.body

    if (!body) {
        sendJSONresponse(res, 400, { message: "All fields required" })
        return
    }

    try {
        const review = await Review.findById(req.params.id)
        if (!review) {
            sendJSONresponse(res, 404, { message: `No review with ID ${req.params.id}` })
            return
        }
        if (review.reviewer.toString() !== req.currentUser.sub && !req.currentUser.admin) {
            sendJSONresponse(res, 403, { message: "You need admin privileges to edit someone else's review" })
            return
        }

        review.body = body
        review.start = start ? Date.parse(start) : null
        review.stop = stop ? Date.parse(stop) : null

        await review.save()
        sendJSONresponse(res, 200, review)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.deleteOne = async (req, res) => {
    try {
        const review = await Review.findById(req.params.id)
        if (!review) {
            sendJSONresponse(res, 404, { message: `No review with ID ${req.params.id}` })
            return
        }
        if (review.reviewer.toString() !== req.currentUser.sub && !req.currentUser.admin) {
            sendJSONresponse(res, 403, { message: "You need admin privileges to delete someone else's review" })
            return
        }

        await Review.deleteOne({ _id: req.params.id })
        sendJSONresponse(res, 204, null)
    } catch(err) {
        sendJSONresponse(res, 404, err)
    }
}

module.exports.deleteAll = async (req, res) => {
    try {
        if (req.currentUser.admin) {
            await Review.deleteMany()
        } else {
            await Review.deleteMany({ reviewer: req.currentUser.sub })
        }

        sendJSONresponse(res, 204, null)
    } catch(err) {
        sendJSONresponse(res, 404, err)
    }
}
