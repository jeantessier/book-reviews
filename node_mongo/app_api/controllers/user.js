const mongoose = require('mongoose');
const User = mongoose.model('User');

const sendJSONresponse = (res, status, content) => {
    res.status(status);
    res.json(content);
};

module.exports.list = (req, res) => {
    User.find((err, users) => {
        if (err) {
            sendJSONresponse(res, 400, err);
            return;
        }

        sendJSONresponse(res, 200, users);
    });
};

module.exports.create = (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    if (!req.body.name || !req.body.email || !req.body.password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    const user = new User();

    user.name = req.body.name;
    user.email = req.body.email;
    user.roles = req.body.roles ? req.body.roles : ["ROLE_USER"];

    user.setPassword(req.body.password);

    user.save(err => {
        if (err) {
            sendJSONresponse(res, 400, err);
            return;
        }

        sendJSONresponse(res, 201, user);
    });
};

module.exports.readOne = (req, res) => {
    User.findOne({ _id: req.params.id }, (err, user) => {
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        } else if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        sendJSONresponse(res, 200, user);
    });
};

module.exports.updateOne = (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    User.findOne({ _id: req.params.id }, (err, user) => {
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        } else if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        if (req.body.name) {
            user.name = req.body.name;
        }
        if (req.body.email) {
            user.email = req.body.email;
        }
        if (req.body.roles) {
            user.roles = req.body.roles;
        }
        if (req.body.password) {
            user.setPassword(req.body.password);
        }

        user.save(err => {
            if (err) {
                sendJSONresponse(res, 400, err);
                return;
            }

            sendJSONresponse(res, 200, user);
        });
    });
};

module.exports.replaceOne = (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    if (!req.body.name || !req.body.email || !req.body.password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    User.findOne({ _id: req.params.id }, (err, user) => {
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        } else if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        user.name = req.body.name;
        user.email = req.body.email;
        user.roles = req.body.roles ? req.body.roles : ["ROLE_USER"];

        user.setPassword(req.body.password);

        user.save(err => {
            if (err) {
                sendJSONresponse(res, 400, err);
                return;
            }

            sendJSONresponse(res, 200, user);
        });
    });
};

module.exports.deleteOne = (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    User.findOneAndDelete({ _id: req.params.id }, (err, user) => {
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        } else if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        sendJSONresponse(res, 204, null);
    });
};
