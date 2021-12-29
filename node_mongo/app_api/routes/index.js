const express = require('express')
const router = express.Router()

const routesAuthentication = require('./authentication')
router.use("/", routesAuthentication)

const routesBook = require('./book')
router.use("/book", routesBook)

const routesReview = require('./review')
router.use("/review", routesReview)

const routesUser = require('./user')
router.use("/user", routesUser)

const routesMe = require('./me')
router.use("/me", routesMe)

module.exports = router
