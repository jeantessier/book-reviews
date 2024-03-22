const mongoose = require('mongoose')
const Review = mongoose.model('Review')
const User = mongoose.model('User')

const sendJSONresponse = (res, status, content) => res.status(status).json(content)

module.exports.list = (req, res) => {
    return User
        .find()
        .select('-salt -hash')
        .populate('numReviews')
        .then(users => sendJSONresponse(res, 200, users))
        .catch(err => sendJSONresponse(res, 400, err))
}

module.exports.create = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    const { name, email, password, roles } = req.body

    if (!name || !email || !password) {
        sendJSONresponse(res, 400, { message: "All fields required" })
        return
    }

    const usedEmail = await User.findOne({ email })
    if (usedEmail) {
        sendJSONresponse(res, 409, { message: `There is already a user with ${email}` })
        return
    }

    const user = new User({
        name,
        email,
        roles: roles ? roles : ["ROLE_USER"],
    })

    user.setPassword(password)

    try {
        await user.save()
        sendJSONresponse(res, 201, user)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.readOne = (req, res) => {
    return User
        .findById(req.params.id)
        .select('-salt -hash')
        .populate('numReviews')
        .populate('reviews')
        .then(user => {
            if (user) {
                sendJSONresponse(res, 200, user)
            } else {
                sendJSONresponse(res, 404, { message: `No user with ID ${req.params.id}` })
            }
        }).catch(err => sendJSONresponse(res, 400, err))
}

module.exports.updateOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    try {
        const user = await User.findById(req.params.id)
        if (!user) {
            sendJSONresponse(res, 404, { message: `No user with ID ${req.params.id}` })
            return
        }

        const { name, email, password, roles } = req.body

        if (name) {
            user.name = name
        }
        if (email) {
            user.email = email
        }
        if (roles) {
            user.roles = roles
        }
        if (password) {
            user.setPassword(password)
        }

        await user.save()
        sendJSONresponse(res, 200, user)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.replaceOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    const { name, email, password, roles } = req.body

    if (!name || !email || !password) {
        sendJSONresponse(res, 400, { message: "All fields required" })
        return
    }

    try {
        const user = await User.findById(req.params.id)
        if (!user) {
            sendJSONresponse(res, 404, { message: `No user with ID ${req.params.id}` })
            return
        }

        user.name = name
        user.email = email
        user.roles = roles ? roles : ["ROLE_USER"]

        user.setPassword(password)

        await user.save()
        sendJSONresponse(res, 200, user)
    } catch(err) {
        sendJSONresponse(res, 400, err)
    }
}

module.exports.deleteOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    try {
        const user = await User.findByIdAndDelete(req.params.id)
        if (user) {
            await Review.deleteMany({ reviewer: req.params.id })
            sendJSONresponse(res, 204, null)
        } else {
            sendJSONresponse(res, 404, { message: `No user with ID ${req.params.id}` })
        }
    } catch(err) {
        sendJSONresponse(res, 404, err)
    }
}

module.exports.deleteAll = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    try {
        await User.deleteMany()
        await Review.deleteMany()
        sendJSONresponse(res, 204, null)
    } catch(err) {
        sendJSONresponse(res, 404, err)
    }
}

module.exports.listUserReviews = (req, res) => {
    Review
        .find({ reviewer: req.params.id })
        .then(reviews => sendJSONresponse(res, 200, reviews))
        .catch(err => sendJSONresponse(res, 400, err))
}

module.exports.deleteAllUserReviews = (req, res) => {
    if (req.params.id !== req.currentUser.sub && !req.currentUser.admin) {
        sendJSONresponse(res, 403, { message: "You need admin privileges for this operation" })
        return
    }

    Review
        .deleteMany({ reviewer: req.params.id })
        .then(_ => sendJSONresponse(res, 204, null))
        .catch(err => sendJSONresponse(res, 404, err))
}
