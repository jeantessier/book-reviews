# Rails with MySQL

This is a Ruby on Rails application backed by a MySQL database.

* Ruby version: `2.6.6`
* Rails version: `6.0.3.3`

## MySQL

These commands will create a new database named
`rails_mysql_book_reviews_development` and populate it with data derived from
`../data/Books_????-??-??*.md`.

```bash
$ bin/rails db:setup
$ ./Books_rails_mysql.pl | mysql -u root
```

## Running the Tests

You can run all the tests with:

```bash
$ bin/rspec
```

## Running the Server

You can start the application with:

```bash
$ bin/rails server
```

And use the base URL http://localhost:3000.

> The examples below all use [Httpie](https://httpie.org/) to call the server
> from the command-line.  Feel free to use your favorite tool, such as
> [cURL](https://en.wikipedia.org/wiki/CURL) or
> [Postman](https://www.getpostman.com/) instead.  Httpie is a tool written in
> Python that installs itself in your local Python environment.  You can install
> it with:
>
> ```bash
> $ pip install httpie
> ```
>
> It assumes HTTP and `localhost` by default, so a call can be as simple as:
>
> ```bash
> $ http :3000
> ```

## Making REST Calls

To get a single review:

```bash
$ http :3000/reviews/1
```
```json
{
    "id": 4,
    "reviewer_id": 1,
    "book_id": 4,
    "body": "<p>I'm brushing up on my Ruby.  This book on the Ruby programming language had good reviews on Goodreads, and I like books published by Manning.</p><p><i>More to come.</i></p>",
    "start": "2019-10-07",
    "stop": null,
    "created_at": "2019-11-12T17:43:41.000Z",
    "updated_at": "2019-11-12T17:43:41.000Z"
}
```

Use its `book_id` attribute to fetch the book's details:

```bash
$ http :3000/books/4
```
```json
{
    "id": 4,
    "name": "The_Well_Grounded_Rubyist_3ed",
    "publisher": "Manning",
    "created_at": "2019-11-12T17:43:41.000Z",
    "updated_at": "2019-11-12T17:43:41.000Z"
}
```

And the book's title(s):

```bash
$ http :3000/books/1/titles
```
```json
[
    {
        "id": 4,
        "book_id": 4,
        "title": "The Well-Grounded Rubyist, Third Edition",
        "link": "https://www.amazon.com/dp/1617295213",
        "order": 1
    }
]
```

And the book's author(s):

```bash
$ http :3000/books/1/authors
```
```json
[
    {
        "id": 5,
        "book_id": 4,
        "name": "David A. Black",
        "order": 1
    },
    {
        "id": 6,
        "book_id": 4,
        "name": "Joseph Leo III",
        "order": 2
    }
]
```

And the book's publication history:

```bash
$ http :3000/books/1/years
```
```json
[
    {
        "id": 4,
        "book_id": 4,
        "year": "2019",
        "order": 1
    }
]
```

Use the review's `reviewer_id` attribute to fetch the reviewer's details:

```bash
$ http :3000/users/1
```
```json
{
    "id": 1,
    "email": "jean@jeantessier.com",
    "created_at": "2019-11-12T17:43:41.000Z",
    "updated_at": "2019-11-12T17:43:41.000Z",
    "name": "Jean Tessier"
}
```

This implementation does not let you list all its users, but you can fetch
information about individual users by ID.

```bash
$ http :3000/users/1
```

To get a list of books:

```bash
$ http :3000/books
```

## Making Authenticated REST Calls

You need to login to the application to do any _write_ operations, like
creating, updating, or deleting objects in the system.  You can perform _read_
operations anonymously, if you want.

You will need to create a `User` and generate a JWT token for them.

> For now, use the Rails console to create the `User`.
>
> ```bash
> $ bin/rails console
> ```
> ```ruby
> User.create! name: "Jean Tessier", email: "jean@jeantessier.com", password: "abcd1234"
> ```

Once you have a user, you can get the JWT token from the `/user_token` endpoint.

```bash
$ http \
    POST \
    :3000/user_token \
    auth:='{"email": "jean@jeantessier.com", "password": "abcd1234"}'
```

And you'll get a response that looks like:

```json
{
    "jwt": "eyJ0...P9Pk"
}
```

You can use the JWT to call protected endpoints that require authentication.

To create a book:

```bash
$ http \
    POST \
    :3000/books \
    Authentication:"Bearer eyJ0...P9Pk" \
    name=The_Hobbit \
    publisher="Houghton Mifflin"
```

Since putting the JWT on every command-line is tedious, you can tell Httpie to
fetch it from your shell's environment.

```bash
$ pip install httpie-jwt-auth
$ export JWT_AUTH_TOKEN=eyJ0...P9Pk
$ http --auth-type jwt POST :3000/books name=The_Hobbit publisher="Houghton Mifflin"
```

> Handy one-liner:
> ```bash
> export JWT_AUTH_TOKEN=$(http POST :3000/user_token auth:='{"email": "jean@jeantessier.com", "password": "abcd1234"}' | jq -r '.jwt')
> ```

To update a book:

```bash
$ http --auth-type jwt PATCH :3000/books/1 publisher="Allen & Unwin"
```

To add a title:

```bash
$ http --auth-type jwt POST :3000/books/1/titles title="The Hobbit"
```

To add an author:

```bash
$ http --auth-type jwt POST :3000/books/1/authors name="J.R.R. Tolkien"
```

To add a publication year:

```bash
$ http --auth-type jwt POST :3000/books/1/years year=1937
```

To add a review:

```bash
$ http --auth-type jwt POST :3000/reviews reviewer_id:=1 book_id:=1 body="This book is amazing, so far." start=2019-11-10
```

> Right now, we have to pass in the reviewer's ID explicitly.  It will
> eventually be smart enough to figure out the reviewer based on the JWT.

## Making GraphQL Calls

### Sample Queries

```bash
$ http :3000/graphql query="{me {name user {name email}}}" | jq '.data'
```

You can also issue GraphQL queries with http://localhost:3000/graphiql.

> GraphiQL does not let you set the `Authorization` header to pass in the JWT.
> An alternative is to launch Playground from another application and point it
> to http://localhost:3000/graphql.  Playground allows you to set arbitrary
> headers in the request.

_Come back later for more._

### Making Authenticated GraphQL Calls

Use this mutation to sign in and get a JWT:

```graphql
mutation SignIn($signInInput: SignInMutationInput!) {
  signIn(input: $signInInput) {
    jwt
  }
}
```

With the following variables:

```json
{
  "signInInput": {
    "email": "jean@jeantessier.com",
    "password": "abcd1234"
  }
}
```

The response will look like:

```json
{
  "data": {
    "signIn": {
      "jwt": "eyJ0...P9Pk"
    }
  }
}
```

> Handy one-liner:
> ```bash
> export JWT_AUTH_TOKEN=$(http :3000/graphql query='mutation SignIn($signInInput: SignInMutationInput!) {signIn(input: $signInInput) {jwt}}' variables:='{"signInInput": {"email": "jean@jeantessier.com", "password": "abcd1234"}}' | jq -r '.data.signIn.jwt')
> ```

If the authentication fails, whether it's because the email address is unknown
or because the password doesn't match, you will get an error that will look like
this:

```json
{
    "data": {
        "signIn": null
    },
    "errors": [
        {
            "locations": [
                {
                    "column": 54,
                    "line": 1
                }
            ],
            "message": "Authentication failure",
            "path": [
                "signIn"
            ]
        }
    ]
}
```

### N+1 Problem

Take a query like:

```graphql
query MyBookReviews {
  me {
    user {
      books {
        name
        reviews {
          body
          reviewer {
            name
          }
        }
      }
    }
  }
}
```

It exhibits the `N+1` problem: 1 database query to fetch the _N_ books,  then 1
query per book to fetch its reviews.  In our case so far, each book has only one
review.  Technically, for each review, it issues yet another query to fetch the
reviewer.  But since our current reviews are all authored by the same user,
these are all cached for the time of the request.

You can see it in the Rails log output:

```
Started POST "/graphql" for 127.0.0.1 at 2020-11-04 21:23:20 -0800
   (0.5ms)  SET NAMES utf8,  @@SESSION.sql_mode = CONCAT(CONCAT(@@sql_mode, ',STRICT_ALL_TABLES'), ',NO_AUTO_VALUE_ON_ZERO'),  @@SESSION.sql_auto_is_null = 0, @@SESSION.wait_timeout = 2147483
Processing by GraphqlController#execute as */*
  Parameters: {"operationName"=>"MyBookReviews", "variables"=>{"id"=>2}, "query"=>"query UsersReviews($id: ID!) {\n  reviews(forReviewer: $id) {\n    book {\n      titles {\n        title\n      }\n    }\n    reviewer {\n      name\n    }\n  }\n}\n\nquery Review($id: ID!) {\n  review(reviewId: $id) {\n    book {\n      titles {\n        title\n      }\n    }\n    reviewer {\n      name\n    }\n  }\n}\n\nquery User($id: ID!) {\n  user(userId: $id) {\n    books {\n      titles {\n        title\n      }\n    }\n  }\n}\n\nquery Books {\n  books {\n    name\n  }\n}\n\nquery Book($id: ID!) {\n  book(bookId: $id) {\n    titles {\n      title\n    }\n    reviewers {\n      name\n    }\n  }\n}\n\nquery Me {\n  me {\n    user {\n      books {\n        name\n      }\n    }\n  }\n}\n\nquery MyBookReviews {\n  me {\n    user {\n      books {\n        name\n        reviews {\n          body\n          reviewer {\n            name\n          }\n        }\n      }\n    }\n  }\n}\n", "graphql"=>{"operationName"=>"MyBookReviews", "variables"=>{"id"=>2}, "query"=>"query UsersReviews($id: ID!) {\n  reviews(forReviewer: $id) {\n    book {\n      titles {\n        title\n      }\n    }\n    reviewer {\n      name\n    }\n  }\n}\n\nquery Review($id: ID!) {\n  review(reviewId: $id) {\n    book {\n      titles {\n        title\n      }\n    }\n    reviewer {\n      name\n    }\n  }\n}\n\nquery User($id: ID!) {\n  user(userId: $id) {\n    books {\n      titles {\n        title\n      }\n    }\n  }\n}\n\nquery Books {\n  books {\n    name\n  }\n}\n\nquery Book($id: ID!) {\n  book(bookId: $id) {\n    titles {\n      title\n    }\n    reviewers {\n      name\n    }\n  }\n}\n\nquery Me {\n  me {\n    user {\n      books {\n        name\n      }\n    }\n  }\n}\n\nquery MyBookReviews {\n  me {\n    user {\n      books {\n        name\n        reviews {\n          body\n          reviewer {\n            name\n          }\n        }\n      }\n    }\n  }\n}\n"}}
  User Load (5.8ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1
  Book Load (6.0ms)  SELECT `books`.* FROM `books` INNER JOIN `reviews` ON `books`.`id` = `reviews`.`book_id` WHERE `reviews`.`reviewer_id` = 1
  Review Load (0.4ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`book_id` = 1
  CACHE User Load (0.0ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1  [["id", 1], ["LIMIT", 1]]
  Review Load (0.5ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`book_id` = 2
  CACHE User Load (0.0ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1  [["id", 1], ["LIMIT", 1]]
  Review Load (0.3ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`book_id` = 3
  CACHE User Load (0.0ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1  [["id", 1], ["LIMIT", 1]]
  ...
  Review Load (0.3ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`book_id` = 133
  CACHE User Load (0.0ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1  [["id", 1], ["LIMIT", 1]]
Completed 200 OK in 232ms (Views: 14.7ms | ActiveRecord: 50.0ms | Allocations: 106694)
```

### Extracting the Schema

This will write the schema as
GraphQL Schema Language to `app/graphql/rails_mysql_schema.graphql`.

```bash
$ bin/rake graphql:schema:idl
```

This will write the schema as
GraphQL Schema Language to `app/graphql/rails_mysql_schema.graphql`
and as JSON to `app/graphql/rails_mysql_schema.json`.

```bash
$ bin/rake graphql:schema:dump
```
