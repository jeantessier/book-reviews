# NodeJS with MongoDB

This is a NodeJS application backed by a MongoDB database.

## MongoDB

This command will create a new database named `node_mongo_book_reviews` and
populate it with collections derived from `Books_????-??-??.md`.

```bash
./Books_mongo.pl > book_reviews.js
mongo node_mongo_book_reviews book_reviews.js
```

## Running the Server

You need to configure the secret to sign JWTs and the location of the database
in the `.env` file on the project's top-level folder.  For example:

```
JWT_SECRET=<put your signature secret here>
MONGODB_URI=mongodb://localhost/node_mongo_book_reviews
```

You can start the application with:

```bash
npm start
```

And point your browser to http://localhost:3000.

## Experimental Setup

You can use Docker Compose to run the database and the server together.  This
way, you don't need to install MongoDB explicitly.

```bash
docker compose up -d book_reviews
```

It does make initializing the database a little more difficult.

```bash
./Books_mongo.pl > book_reviews.js
docker cp book_reviews.js node_mongo_mongo_1:/tmp/book_reviews.js
docker compose exec mongo mongo node_mongo_book_reviews /tmp/book_reviews.js
```

## Sample Commands

All examples use [HTTPie](https://httpie.org/).

### Users

#### See All Users

```bash
http :3000/api/user
```

#### See a Single User

```bash
http :3000/api/user/<id>
```

#### Register a New User

```bash
http :3000/api/register \
    email=admin@bookreviews.com \
    password=abcd1234 \
    name=Administrator
```

For the very first admin account, you will need to grant them `ROLE_ADMIN`
manually in MongoDB.

```javascript
db.users.findOneAndUpdate(
    { "name": "Administrator" },
    { $addToSet: { roles: "ROLE_ADMIN" } }
);
```

> If you are using the experimental setup with Docker Compose to run the server,
> you can get into the database with:
> 
> ```bash
> docker compose exec mongo mongo node_mongo_book_reviews
> ```
>
> You do need the double "mongo" in the command above. The first one is the name
> of the database container under Docker Compose.  The second one is the MongoDB
> CLI shell.

Once you have a functioning admin user, you can use it to grant `ROLE_ADMIN` to
other users, using the `PATCH` verb.

#### Login as a User

```bash
http :3000/api/login \
    email=admin@bookreviews.com \
    password=abcd1234
```

which outputs:

```json
{
    "token": "eyJh...IET4"
}
```

You can use the token as a `Bearer` authentication in subsequent calls.  You can
observe its contents at [jwt.io](https://jwt.io/).

If you don't want to enter the token with every request, you can save it with:

```bash
export JWT_AUTH_TOKEN=eyJh...IET4
```

> Handy one-liner:
> 
> ```bash
> export JWT_AUTH_TOKEN=$(http :3000/api/login email=admin@bookreviews.com password=abcd1234 | jq --raw-output '.token')
> ```

And then call HTTPie with `--auth-type jwt`.

#### Create an Arbitrary User (Admin-Only)

```bash
http --auth-type jwt :3000/api/user \
    email=john@doe.com \
    password=abcd1234 \
    name="John Doe"
```

The difference with `/api/register` is that you can specify `roles`.

```bash
http --auth-type jwt :3000/api/user \
    email=jane@doe.com \
    password=abcd1234 \
    name="Jane Doe" \
    roles:='["ROLE_ADMIN", "ROLE_USER"]'
```

If you do not specify `roles`, they get `ROLE_USER` by default.

#### Modify Parts of a User

You can change a user's `roles` with:

```bash
http --auth-type jwt PATCH :3000/api/user/<id> \
    roles:='["ROLE_ADMIN", "ROLE_USER"]'
```

You can reset a user's password with:

```bash
http --auth-type jwt PATCH :3000/api/user/<id> \
    password=abcd1234
```

#### Modify an Entire User

```bash
http --auth-type jwt PUT :3000/api/user/<id> \
        email=gandalf@middle-earth.com \
        password=abcd1234 \
        name="Gandalf the Grey"
```

The `roles` will revert to `ROLE_USER` unless you provide them explicitly.

#### Remove a User (Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/user/<id>
```

This will also delete the reviews made by this user.

#### Remove All Users (Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/user
```

This will delete all users, including the admin account.  The user will still be
able to act in the system for as long as their JWT is valid.

This will also delete all reviews.

### Books

#### See All Books

```bash
http :3000/api/book
```

#### See a Single Book

```bash
http :3000/api/book/<id>
```

#### Create a Book (Admin-Only)

```bash
http --auth-type jwt :3000/api/book \
    name=The_Lord_of_the_Rings \
    titles:='[{"title": "The Lord of the Rings", "link": "http://lotr.wikia.com"}, {"title": "Le seigneur des anneaux"}]' \
    authors="J. R. R. Tolkien" \
    publisher="Allen &amp; Unwin" \
    years:='["1954", "1955"]'
```

```bash
http --auth-type jwt :3000/api/book \
    name=The_Silmarillion \
    titles:='[{"title": "The Silmarillion"}]' \
    authors:='["J. R. R. Tolkien", "Christopher Tolkien"]' \
    publisher="Allen &amp; Unwin" \
    years=1977
```

It will fail if there is already a book by that `name`.

#### Modify Parts of a Book (Admin-Only)

```bash
http --auth-type jwt PATCH :3000/api/book/<id> \
    titles:='[{"title": "The Lord of the Rings", "link": "http://lotr.wikia.com"}, {"title": "Le seigneur des anneaux"}]' \
    years:='["1954", "1955"]'
```

#### Modify an Entire Book (Admin-Only)

```bash
http --auth-type jwt PUT :3000/api/book/<id> \
    name=The_Silmarillion \
    titles:='[{"title": "The Silmarillion"}]' \
    authors:='["J. R. R. Tolkien", "Christopher Tolkien"]' \
    publisher="Allen &amp; Unwin" \
    years=1977
```

It will fail if there is already another book by that `name`.

#### Remove a Book (Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/book/<id>
```

This will also delete all reviews for this book.

#### Remove All Books (Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/book
```

This will also delete all reviews.

### Reviews

#### See All Reviews

```bash
http :3000/api/review
```

```bash
http :3000/api/review | jq '.|length'
```

This second command uses `jq` to show the total number of reviews in the system.

#### See All Reviews For a Given Book

```bash
http :3000/api/review \
    | jq '.|map(select(.book == "<book id>"))'
```

This command uses `jq` to pick specific reviews from the full list.

```bash
http :3000/api/review \
    | jq '.|map(select(.book == "<book id>"))|map({_id, body, start, stop})'
```

This command also uses `jq` to narrow down the output to just a few, specific
fields of the reviews.

#### See a Single Review

```bash
http :3000/api/review/<id>
```

#### Create a Review

```bash
http --auth-type jwt :3000/api/review \
    book=<book id> \
    reviewer=<user id> \
    start="2019-03-13" \
    body="This is the text of the review.\n\nYou have to escape newlines."
```

It will fail if there is no book with that ID, or if the reviewer does not
exist.  It will also fail if there is already a review of that book by that
reviewer.

Admins can override the `reviewer`.  Otherwise, it uses the subject of the JWT.

#### Modify Parts of a Review (Owner- or Admin-Only)

You can set the `stop` date and change the review with:

```bash
http --auth-type PATCH jwt :3000/api/review/<id> \
    stop="2019-03-23" \
    body="This is the new text of the review."
```

With this example, the `start` date is left unchanged.

Admins can edit any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Modify an Entire Review (Owner- or Admin-Only)

```bash
http --auth-type jwt PUT :3000/api/review/<id> \
    email=gandalf@middle-earth.com \
    stop="2019-03-23" \
    body="This is the new text of the review."
```

With this example, the `start` date is set to `null` since it is not included in
the call's payload.

Admins can edit any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Remove a Review (Owner- or Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/review/<id>
```

Admins can delete any review.  Otherwise, the subject of the JWT must match the
author of the review.

#### Remove All Reviews (Owner- or Admin-Only)

```bash
http --auth-type jwt DELETE :3000/api/review
```

Admins will delete **all** reviews.  Otherwise, the subject of the JWT will
delete all of **their** own reviews.

### My Data

Once logged in, you can see data for the current user, as identified by the JWT.

#### See Me

```bash
http --auth-type jwt :3000/api/me
```

#### See My Reviews

```bash
http --auth-type jwt :3000/api/me/review
```

```bash
$ http --auth-type jwt :3000/api/me/review | jq '.|length'
```

This second command uses `jq` to show the total number of reviews by the current
user.

#### See a Single Review

```bash
http --auth-type jwt :3000/api/me/review/<id>
```

This can only show reviews by the current user.

#### Create a Review

```bash
http --auth-type jwt :3000/api/me/review \
    book=<book id> \
    start="2019-03-13" \
    body="This is the text of the review.\n\nYou have to escape newlines."
```

It will fail if there is no book with that ID.  It will fail if there is already
a review of that book by the current user.

#### Modify Parts of My Review

You can set the `stop` date and change the review with:

```bash
http --auth-type PATCH jwt :3000/api/me/review/<id> \
    stop="2019-03-23" \
    body="This is the new text of the review."
```

With this example, the `start` date is left unchanged.

#### Modify My Entire Review

```bash
http --auth-type jwt PUT :3000/api/me/review/<id> \
    email=gandalf@middle-earth.com \
    stop="2019-03-23" \
    body="This is the new text of the review."
```

With this example, the `start` date is set to `null` since it is not included in
the call's payload.

#### Remove My Review

```bash
http --auth-type jwt DELETE :3000/api/me/review/<id>
```

#### Remove All My Reviews

```bash
http --auth-type jwt DELETE :3000/api/me/review
```

#### Remove Me

```bash
http --auth-type jwt DELETE :3000/api/me
```

This will also delete all the current user's reviews.
