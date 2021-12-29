const express = require('express')
const router = express.Router()

const ctrlAuth = require('../controllers/authentication')

router
    .post('/register', ctrlAuth.register)
    .post('/login', ctrlAuth.login)

module.exports = router
