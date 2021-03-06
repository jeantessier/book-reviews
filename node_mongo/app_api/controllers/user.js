const mongoose = require('mongoose');
const User = mongoose.model('User');

const sendJSONresponse = (res, status, content) => {
    res.status(status);
    res.json(content);
};

module.exports.list = async (req, res) => {
    try {
        const users = await User.find();
        sendJSONresponse(res, 200, users);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.create = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    const { name, email, password, roles } = req.body;

    if (!name || !email || !password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    const user = new User({
        name,
        email,
        roles: roles ? roles : ["ROLE_USER"],
    });

    user.setPassword(password);

    try {
        await user.save();
        sendJSONresponse(res, 201, user);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.readOne = async (req, res) => {
    try {
        const user = await User.findOne({ _id: req.params.id });
        if (user) {
            sendJSONresponse(res, 200, user);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.updateOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        const user = await User.findOne({ _id: req.params.id })
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        }

        const { name, email, password, roles } = req.body;

        if (name) {
            user.name = name;
        }
        if (email) {
            user.email = email;
        }
        if (roles) {
            user.roles = roles;
        }
        if (password) {
            user.setPassword(password);
        }

        await user.save()
        sendJSONresponse(res, 200, user);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.replaceOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    const { name, email, password, roles } = req.body;

    if (!name || !email || !password) {
        sendJSONresponse(res, 400, {
            "message": "All fields required"
        });
        return;
    }

    try {
        const user = await User.findOne({ _id: req.params.id });
        if (!user) {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
            return;
        }

        user.name = name;
        user.email = email;
        user.roles = roles ? roles : ["ROLE_USER"];

        user.setPassword(password);

        await user.save();
        sendJSONresponse(res, 200, user);
    } catch(err) {
        sendJSONresponse(res, 400, err);
    }
};

module.exports.deleteOne = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        const user = await User.findOneAndDelete({ _id: req.params.id });
        if (user) {
            sendJSONresponse(res, 204, null);
        } else {
            sendJSONresponse(res, 404, {
                "message": `No user with ID ${req.params.id}`
            });
        }
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};

module.exports.deleteAll = async (req, res) => {
    if (!req.currentUser.admin) {
        sendJSONresponse(res, 403, {
            "message": "You need admin privileges for this operation"
        });
        return;
    }

    try {
        await User.deleteMany();
        sendJSONresponse(res, 204, null);
    } catch(err) {
        sendJSONresponse(res, 404, err);
    }
};
