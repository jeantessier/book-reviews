# NodeJS with MongoDB

This is a NodeJS application backed by a MongoDB database.

## MongoDB

This command will create a new database named `node_mongo_book_reviews` and
populate it with collections derived from `Books_????-??-??.txt`.

    $ ./Books_mongo.pl > book_reviews.js
    $ mongo node_mongo_book_reviews book_reviews.js

## Running the Server

You can start the application with:

    $ npm start

And point your browser to http://localhost:3000.

## Sample Commands

The examples use [HTTPie](https://httpie.org/).

### See All Users

    $ http :3000/api/user

### See a Single Users

    $ http :3000/api/user/<id>

### Register a New User

    $ http :3000/api/register \
        email=admin@bookreviews.com \
        password=abcd1234 \
        name=Administrator

For the very first admin account, you will need to grant them `ROLE_ADMIN`
manually in MongoDB.

    db.users.findOneAndUpdate(
        { "name": "Administrator" },
        { $addToSet: { roles: "ROLE_ADMIN" } }
    );

Once you have a functioning admin user, you can use it to grant `ROLE_ADMIN` to
other users, using the `PATCH` verb.

### Login as a User

    $ http :3000/api/login \
        email=admin@bookreviews.com \
        password=abcd1234

which outputs:

    {
        "token": "eyJh...IET4"
    }

You can use the token as a `Bearer` authentication in subsequent calls.  You can
observe its contents at [jwt.io](https://jwt.io/).

### Create an Arbitrary User (Admin-Only)

    $ http :3000/api/user \
        Authorization:"Bearer eyJh...IET4" \
        email=john@doe.com \
        password=abcd1234 \
        name="John Doe"

The difference with `/api/register` is that you can specify `roles`.

    $ http :3000/api/user \
        Authorization:"Bearer eyJh...IET4" \
        email=jane@doe.com \
        password=abcd1234 \
        name="Jane Doe" \
        roles:='["ROLE_ADMIN", "ROLE_USER"]'

If you do not specify `roles`, they get `ROLE_USER` by default.

### Modify Parts of a User

You can change a user's `roles` with:

    $ http PATCH :3000/api/user/<id> \
        Authorization:"Bearer eyJh...IET4" \
        roles:='["ROLE_ADMIN", "ROLE_USER"]'

You can reset a user's password with:

    $ http PATCH :3000/api/user/<id> \
        Authorization:"Bearer eyJh...IET4" \
        password=abcd1234

### Modify an Entire User

    $ http PUT :3000/api/user/<id> \
        Authorization:"Bearer eyJh...IET4" \
        email=gandalf@middle-earth.com \
        password=abcd1234 \
        name="Gandalf the Grey"

The `roles` will revert to `ROLE_USER` unless you provide them explicitly.

### Remove a User

    $ http DELETE :3000/api/user/<id> \
        Authorization:"Bearer eyJh...IET4"
