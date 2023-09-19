const express = require('express')
const router = express.Router()
const { expressjwt: jwt } = require('express-jwt')
const auth = jwt({
    secret: process.env.JWT_SECRET,
    requestProperty: 'currentUser',
    algorithms: ['HS256'],
})

const ctrlUser = require('../controllers/user')

router
    .route("/")
    .get(ctrlUser.list)
    .post(auth, ctrlUser.create)
    .delete(auth, ctrlUser.deleteAll)

router
    .route("/:id")
    .get(ctrlUser.readOne)
    .patch(auth, ctrlUser.updateOne)
    .put(auth, ctrlUser.replaceOne)
    .delete(auth, ctrlUser.deleteOne)

router
    .route("/:id/reviews")
    .get(ctrlUser.listUserReviews)
    .delete(auth, ctrlUser.deleteAllUserReviews)

module.exports = router
