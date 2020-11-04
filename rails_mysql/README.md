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
$ http :3000/graphql query="{testField}" | jq '.data'
```

You can also issue GraphQL queries with http://localhost:3000/graphiql.

_Come back later for more._

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
