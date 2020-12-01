const express = require('express');
const router = express.Router();
const jwt = require('express-jwt');
const auth = jwt({
    secret: process.env.JWT_SECRET,
    userProperty: 'currentUser'
});

const ctrlBook = require('../controllers/book');

router
    .route("/")
    .get(ctrlBook.list)
    .post(auth, ctrlBook.create);

router
    .route("/:id")
    .get(ctrlBook.readOne)
    .patch(auth, ctrlBook.updateOne)
    .put(auth, ctrlBook.replaceOne)
    .delete(auth, ctrlBook.deleteOne);

module.exports = router;
