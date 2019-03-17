const express = require('express');
const router = express.Router();

const routesAuthentication = require('./authentication');
router.use("/", routesAuthentication);

const routesUser = require('./user');
router.use("/user", routesUser);

module.exports = router;
