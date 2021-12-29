const mongoose = require('mongoose');
const Book = mongoose.model('Book');
const Review = mongoose.model('Review');
const User = mongoose.model('User');

const sendJSONresponse = (res, status, content) => {
    res.status(status);
    res.json(content);
};

module.exports.readMe = async (req, res) => {
    try {
        const user = await User.findOne({ _id: req.currentUser.sub }).select("-salt -hash");
        if (user) {
            sendJSONresponse(res, 200, user);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.currentUser.sub}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.updateMe = async (req, res) => {
    try {
        const user = await User.findOne({ _id: req.currentUser.sub })
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.currentUser.sub}`
            });
            return;
        }

        const { name, email, password } = req.body;

        if (name) {
            user.name = name;
        }
        if (email) {
            user.email = email;
        }
        if (password) {
            user.setPassword(password);
        }

        await user.save()
        sendJSONresponse(res, 200, user);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.replaceMe = async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const user = await User.findOne({ _id: req.currentUser.sub });
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.currentUser.sub}`
            });
            return;
        }

        user.name = name;
        user.email = email;

        user.setPassword(password);

        await user.save();
        sendJSONresponse(res, 200, user);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.deleteMe = async (req, res) => {
    try {
        const user = await User.findOneAndDelete({ _id: req.currentUser.sub });
        if (user) {
            await Review.deleteMany({ reviewer: req.currentUser.sub });
            sendJSONresponse(res, 204, null);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.currentUser.sub}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.listMyReviews = async (req, res) => {
    try {
        const reviews = await Review.find({ reviewer: req.currentUser.sub });
        sendJSONresponse(res, 200, reviews);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.createMyReview = async (req, res) => {
    const { book, body, start, stop } = req.body;
    const reviewer = req.currentUser.sub;

    if (!book || !body) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const [ actualReviewer, actualBook, actualReview ] = await Promise.all([
            User.findOne({ _id: reviewer }),
            Book.findOne({ _id: book }),
            Review.findOne({ reviewer, book }),
        ]);

        if (!actualReviewer) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${reviewer}`
            });
            return;
        }
        if (!actualBook) {
            sendJSONresponse(res, 404, {
                "message": `No book with ID ${book}`
            });
            return;
        }
        if (actualReview) {
            sendJSONresponse(res, 409, {
                "message": `There is already a review of book ${book} by reviewer ${reviewer}`
            });
            return;
        }

        const review = new Review({
            book,
            reviewer,
            body,
            start,
            stop,
        });

        await review.save();
        sendJSONresponse(res, 201, review);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.readMyReview = async (req, res) => {
    try {
        const review = await Review.findOne({ _id: req.params.reviewId, reviewer: req.currentUser.sub });
        if (!review) {
            sendJSONresponse(res, 404, {
                "message": `No review with ID ${req.params.reviewId}`
            });
            return;
        }

        sendJSONresponse(res, 200, review);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.updateMyReview = async (req, res) => {
    try {
        const review = await Review.findOne({ _id: req.params.reviewId, reviewer: req.currentUser.sub })
        if (!review) {
            sendJSONresponse(res, 404, {
                "message": `No review with ID ${req.params.reviewId}`
            });
            return;
        }

        const { body, start, stop } = req.body;

        if (body) {
            review.body = body;
        }
        if (start) {
            review.start = Date.parse(start);
        }
        if (stop) {
            review.stop = Date.parse(stop);
        }

        await review.save()
        sendJSONresponse(res, 200, review);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.replaceMyReview = async (req, res) => {
    const { body, start, stop } = req.body;

    if (!body) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const review = await Review.findOne({ _id: req.params.reviewId, reviewer: req.currentUser.sub });
        if (!review) {
            sendJSONresponse(res, 404, {
                "message": `No review with ID ${req.params.reviewId}`
            });
            return;
        }

        review.body = body;
        review.start = start ? Date.parse(start) : null;
        review.stop = stop ? Date.parse(stop) : null;

        await review.save();
        sendJSONresponse(res, 200, review);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.deleteMyReview = async (req, res) => {
    try {
        const review = await Review.findOne({ _id: req.params.reviewId, reviewer: req.currentUser.sub });
        if (!review) {
            sendJSONresponse(res, 404, {
                "message": `No review with ID ${req.params.reviewId}`
            });
            return;
        }

        await Review.deleteOne({ _id: req.params.reviewId, reviewer: req.currentUser.sub });
        sendJSONresponse(res, 204, null);
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.deleteAllMyReviews = async (req, res) => {
    try {
        await Review.deleteMany({ reviewer: req.currentUser.sub });
        sendJSONresponse(res, 204, null);
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};
