const express = require('express')
const router = express.Router()
const { expressjwt: jwt } = require('express-jwt')
const auth = jwt({
    secret: process.env.JWT_SECRET,
    requestProperty: 'currentUser',
    algorithms: ['HS256'],
})

const ctrlReview = require('../controllers/review')

router
    .route("/")
    .get(ctrlReview.list)
    .post(auth, ctrlReview.create)
    .delete(auth, ctrlReview.deleteAll)

router
    .route("/:id")
    .get(ctrlReview.readOne)
    .patch(auth, ctrlReview.updateOne)
    .put(auth, ctrlReview.replaceOne)
    .delete(auth, ctrlReview.deleteOne)

module.exports = router
