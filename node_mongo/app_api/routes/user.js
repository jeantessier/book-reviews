const express = require('express');
const router = express.Router();

const ctrlUser = require('../controllers/user');

router
    .route("/")
    .get(ctrlUser.list)
    .post(ctrlUser.create);

router
    .route("/:id")
    .get(ctrlUser.readOne)
    .patch(ctrlUser.updateOne)
    .put(ctrlUser.replaceOne)
    .delete(ctrlUser.deleteOne);

module.exports = router;
