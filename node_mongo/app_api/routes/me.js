const express = require('express')
const router = express.Router()
const { expressjwt: jwt } = require('express-jwt')
const auth = jwt({
    secret: process.env.JWT_SECRET,
    requestProperty: 'currentUser',
    algorithms: ['HS256'],
})

const ctrlMe = require('../controllers/me')

router
    .route("/")
    .get(auth, ctrlMe.readMe)
    .patch(auth, ctrlMe.updateMe)
    .put(auth, ctrlMe.replaceMe)
    .delete(auth, ctrlMe.deleteMe)

router
    .route("/review")
    .get(auth, ctrlMe.listMyReviews)
    .post(auth, ctrlMe.createMyReview)
    .delete(auth, ctrlMe.deleteAllMyReviews)

router
    .route("/review/:reviewId")
    .get(auth, ctrlMe.readMyReview)
    .patch(auth, ctrlMe.updateMyReview)
    .put(auth, ctrlMe.replaceMyReview)
    .delete(auth, ctrlMe.deleteMyReview)

module.exports = router
