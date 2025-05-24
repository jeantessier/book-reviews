const mongoose = require('mongoose')
const crypto = require('crypto')
const jwt = require('jsonwebtoken')

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
        required: true,
    },
    name: {
        type: String,
        required: true,
    },
    hash: String,
    salt: String,
    roles: [String],
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
})

userSchema.virtual('numReviews', {
    ref: 'Review',
    localField: '_id',
    foreignField: 'reviewer',
    count: true,
})
userSchema.virtual('reviews', {
    ref: 'Review',
    localField: '_id',
    foreignField: 'reviewer',
})

/*
 * !!!WARNING!!!   !!!WARNING!!!    !!!WARNING!!!    !!!WARNING!!!    !!!WARNING!!!
 *
 * DO NOT CHANGE THESE METHODS TO USE ES6 ARROW FUNCTIONS.
 * IT WILL BREAK MONGOOSE.
 *
 * See: https://mongoosejs.com/docs/guide.html#methods
 */

userSchema.methods.setPassword = function (password) {
    this.salt = crypto.randomBytes(16).toString('hex')
    this.hash = this.hashPassword(password)
}

userSchema.methods.validPassword = function (password) {
    return this.hash === this.hashPassword(password)
}

userSchema.methods.generateJwt = function () {
    const expiry = new Date()
    expiry.setDate(expiry.getDate() + 7)

    return jwt.sign({
        sub: this._id,
        email: this.email,
        name: this.name,
        admin: this.roles.includes("ROLE_ADMIN"),
        exp: expiry.getTime() / 1000,
    }, process.env.JWT_SECRET)
}

userSchema.methods.hashPassword = function (password) {
    return crypto.pbkdf2Sync(password, this.salt, 4096, 512, "sha256").toString("base64")
}

mongoose.model('User', userSchema)
