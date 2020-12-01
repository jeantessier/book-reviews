const passport = require('passport');
const mongoose = require('mongoose');
const User = mongoose.model('User');

const sendJSONresponse = (res, status, content) => {
    res.status(status);
    res.json(content);
};

module.exports.register = (req, res) => {
    if (!req.body.name || !req.body.email || !req.body.password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    const user = new User();

    user.name = req.body.name;
    user.email = req.body.email;
    user.roles = ["ROLE_USER"];

    user.setPassword(req.body.password);

    user.save(err => {
        if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        const token = user.generateJwt();
        sendJSONresponse(res, 200, {
            "token": token
        });
    });
};

module.exports.login = (req, res) => {
    if (!req.body.email || !req.body.password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    passport.authenticate('local', (err, user, info) => {
        if (err) {
            sendJSONresponse(res, 404, err);
            return;
        }

        if (user) {
            const token = user.generateJwt();
            sendJSONresponse(res, 200, {
                "token": token
            });
        } else {
            sendJSONresponse(res, 401, info);
        }
    }) (req, res);
};
