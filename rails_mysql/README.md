# Rails with MySQL

This is a Ruby on Rails application backed by a MySQL database.

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
Started POST "/graphql" for 127.0.0.1 at 2020-11-05 21:19:36 -0800
Processing by GraphqlController#execute as HTML
  Parameters: {"query"=>"{me {user {books {name reviews {body reviewer {name}}}}}}", "graphql"=>{"query"=>"{me {user {books {name reviews {body reviewer {name}}}}}}"}}
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
Completed 200 OK in 217ms (Views: 11.1ms | ActiveRecord: 44.3ms | Allocations: 100535)
```

After configuring batch loaders, we're able to reduce it significantly by
grouping similar database queries together (and cut the time to process the
request in half).

```
Started POST "/graphql" for 127.0.0.1 at 2020-11-05 21:12:58 -0800
Processing by GraphqlController#execute as HTML
  Parameters: {"query"=>"{me {user {books {name reviews {body reviewer {name}}}}}}", "graphql"=>{"query"=>"{me {user {books {name reviews {body reviewer {name}}}}}}"}}
  User Load (0.3ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1 LIMIT 1
  Review Load (10.5ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`reviewer_id` = 1
  Book Load (2.8ms)  SELECT `books`.* FROM `books` WHERE `books`.`id` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142)
  Review Load (6.1ms)  SELECT `reviews`.* FROM `reviews` WHERE `reviews`.`book_id` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142)
  User Load (0.4ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 1
Completed 200 OK in 104ms (Views: 14.5ms | ActiveRecord: 20.1ms | Allocations: 57589)
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
