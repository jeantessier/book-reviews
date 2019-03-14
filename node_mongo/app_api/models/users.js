const mongoose = require('mongoose');
const ObjectId = mongoose.Schema.Types.ObjectId;
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    hash: String,
    salt: String,
    reviews: [ObjectId]
});

userSchema.methods.setPassword = password => {
    this.salt = crypto.randomBytes(16).toString('hex');
    this.hash = this.hashPassword(password);
};

userSchema.methods.validPassword = password => {
    const hash = this.hashPassword(password);
    return this.hash === hash;
};

userSchema.methods.generateJwt = () => {
    const expiry = new Date();
    expiry.setDate(expiry.getDate() + 7);

    return jwt.sign({
        _id: this._id,
        email: this.email,
        name: this.name,
        exp: parseInt(expiry.getTime() / 1000),
    }, process.env.JWT_SECRET);
};

userSchema.methods.hashPassword = password => {
    return crypto.pbkdf2Sync(password, this.salt, 4096, 512, "sha256").toString("base64");
    // return password;
}

mongoose.model('User', userSchema);
