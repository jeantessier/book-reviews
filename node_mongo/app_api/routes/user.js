const express = require('express')
const router = express.Router()
const jwt = require('express-jwt')
const auth = jwt({
    secret: process.env.JWT_SECRET,
    userProperty: 'currentUser',
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

module.exports = router
