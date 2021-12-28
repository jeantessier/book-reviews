# NodeJS with MongoDB

This is a NodeJS application backed by a MongoDB database.

## MongoDB

This command will create a new database named `node_mongo_book_reviews` and
populate it with collections derived from `Books_????-??-??.md`.

    $ ./Books_mongo.pl > book_reviews.js
    $ mongo node_mongo_book_reviews book_reviews.js

## Running the Server

You need to configure the secret to sign JWTs and the location of the database
in the `.env` file on the project's top-level folder.  For example:

    JWT_SECRET=<put your signature secret here>
    MONGODB_URI=mongodb://localhost/node_mongo_book_reviews

You can start the application with:

    $ npm start

And point your browser to http://localhost:3000.

## Experimental Setup

You can use Docker Compose to run the database and the server together.  This
way, you don't need to install MongoDB explicitly.

    $ docker compose up -d book_reviews

It does make initializing the database a little more difficult.

    $ ./Books_mongo.pl > book_reviews.js
    $ docker cp book_reviews.js node_mongo_mongo_1:/tmp/book_reviews.js
    $ docker compose exec mongo mongo node_mongo_book_reviews /tmp/book_reviews.js

## Sample Commands

All examples use [HTTPie](https://httpie.org/).

### Users

#### See All Users

    $ http :3000/api/user

#### See a Single User

    $ http :3000/api/user/<id>

#### Register a New User

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

> If you are using the experimental setup with Docker Compose to run the server,
> you can get into the database with:
> 
>     $ docker compose exec mongo mongo node_mongo_book_reviews
> 
> You do need the double "mongo" in the command above. The first one is the name
> of the database container under Docker Compose.  The second one is the MongoDB
> CLI shell.

Once you have a functioning admin user, you can use it to grant `ROLE_ADMIN` to
other users, using the `PATCH` verb.

#### Login as a User

    $ http :3000/api/login \
        email=admin@bookreviews.com \
        password=abcd1234

which outputs:

    {
        "token": "eyJh...IET4"
    }

You can use the token as a `Bearer` authentication in subsequent calls.  You can
observe its contents at [jwt.io](https://jwt.io/).

If you don't want to enter the token with every request, you can save it with:

    $ export JWT_AUTH_TOKEN=eyJh...IET4

> Handy one-liner:
> 
>     $ export JWT_AUTH_TOKEN=$(http :3000/api/login email=admin@bookreviews.com password=abcd1234 | jq --raw-output '.token')

And then call HTTPie with `--auth-type jwt`.

#### Create an Arbitrary User (Admin-Only)

    $ http --auth-type jwt :3000/api/user \
        email=john@doe.com \
        password=abcd1234 \
        name="John Doe"

The difference with `/api/register` is that you can specify `roles`.

    $ http --auth-type jwt :3000/api/user \
        email=jane@doe.com \
        password=abcd1234 \
        name="Jane Doe" \
        roles:='["ROLE_ADMIN", "ROLE_USER"]'

If you do not specify `roles`, they get `ROLE_USER` by default.

#### Modify Parts of a User

You can change a user's `roles` with:

    $ http --auth-type jwt PATCH :3000/api/user/<id> \
        roles:='["ROLE_ADMIN", "ROLE_USER"]'

You can reset a user's password with:

    $ http --auth-type jwt PATCH :3000/api/user/<id> \
        password=abcd1234

#### Modify an Entire User

    $ http --auth-type jwt PUT :3000/api/user/<id> \
        email=gandalf@middle-earth.com \
        password=abcd1234 \
        name="Gandalf the Grey"

The `roles` will revert to `ROLE_USER` unless you provide them explicitly.

#### Remove a User (Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/user/<id>

#### Remove All Users (Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/user

This will delete all users, including the admin account.  The user will still be
able to act in the system for as long as their JWT is valid.

### Books

#### See All Books

    $ http :3000/api/book

#### See a Single Book

    $ http :3000/api/book/<id>

#### Create a Book (Admin-Only)

    $ http --auth-type jwt :3000/api/book \
        name=The_Lord_of_the_Rings \
        titles:='[{"title": "The Lord of the Rings", "link": "http://lotr.wikia.com"}, {"title": "Le seigneur des anneaux"}]' \
        authors="J. R. R. Tolkien" \
        publisher="Allen &amp; Unwin" \
        years:='["1954", "1955"]'

    $ http --auth-type jwt :3000/api/book \
        name=The_Silmarillion \
        titles:='[{"title": "The Silmarillion"}]' \
        authors:='["J. R. R. Tolkien", "Christopher Tolkien"]' \
        publisher="Allen &amp; Unwin" \
        years=1977

It will fail if there is already a book by that `name`.

#### Modify Parts of a Book (Admin-Only)

    $ http --auth-type jwt PATCH :3000/api/book/<id> \
        titles:='[{"title": "The Lord of the Rings", "link": "http://lotr.wikia.com"}, {"title": "Le seigneur des anneaux"}]' \
        years:='["1954", "1955"]'

#### Modify an Entire Book (Admin-Only)

    $ http --auth-type jwt PUT :3000/api/book/<id> \
        name=The_Silmarillion \
        titles:='[{"title": "The Silmarillion"}]' \
        authors:='["J. R. R. Tolkien", "Christopher Tolkien"]' \
        publisher="Allen &amp; Unwin" \
        years=1977

It will fail if there is already another book by that `name`.

#### Remove a Book (Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/book/<id>

#### Remove All Books (Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/book

### Reviews

#### See All Reviews

    $ http :3000/api/review

```
$ http :3000/api/review | jq '.|length'
```

This second command uses `jq` to show the total number of reviews in the system.

#### See All Reviews For a Given Book

    $ http :3000/api/review \
        | jq '.|map(select(.book == "<book id>"))'

This command uses `jq` to pick specific reviews from the full list.

    $ http :3000/api/review \
        | jq '.|map(select(.book == "<book id>"))|map({_id, body, start, stop})'

This command also uses `jq` to narrow down the output to just a few, specific
fields of the reviews.

#### See a Single Review

    $ http :3000/api/review/<id>

#### Create a Review

    $ http --auth-type jwt :3000/api/review \
        book=<book id> \
        reviewer=<user id> \
        start="2019-03-13" \
        body="This is the text of the review.\n\nYou have to escape newlines."

It will fail if there is no book with that ID, or if the reviewer does not
exist.  It will also fail if there is already a review of that book by that
reviewer.

Admins can override the `reviewer`.  Otherwise, it uses the subject of the JWT.

#### Modify Parts of a Review (Owner- or Admin-Only)

You can set the `stop` date and change the review with:

    $ http --auth-type PATCH jwt :3000/api/review/<id> \
        stop="2019-03-23" \
        body="This is the new text of the review."

With this example, the `start` date is left unchanged.

Admins can edit any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Modify an Entire Review (Owner- or Admin-Only)

    $ http --auth-type jwt PUT :3000/api/review/<id> \
        email=gandalf@middle-earth.com \
        stop="2019-03-23" \
        body="This is the new text of the review."

With this example, the `start` date is set to `null` since it is not included in
the call's payload.

Admins can edit any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Remove a Review (Owner- or Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/review/<id>

Admins can delete any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Remove All Reviews (Owner- or Admin-Only)

    $ http --auth-type jwt DELETE :3000/api/review

Admins will delete **all** reviews.  Otherwise, the subject of the JWT will
delete all of **their** own reviews.
