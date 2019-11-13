# Rails with MySQL

This is a Ruby on Rails application backed by a MySQL database.

* Ruby version: `2.4.3`
* Rails version: `5.0.7.2`

## MySQL

This command will create a new database named `rails_mysql_book_reviews` and
populate it with data derived from `../data/Books_????-??-??.txt`.

    $ bin/rake db:setup
    $ ./Books_rails_mysql.pl | mysql -u root

## Running the Tests

You can run all the tests with:

    $ bundle exec rspec

## Running the Server

You can start the application with:

    $ ./bin/rails server

And use the base URL http://localhost:3000.

## Making REST Calls

To get a list of users:

    $ http :3000/users

To get a list of books:

    $ http :3000/books

To get the book with ID 2:

    $ http :3000/books/2

## Making Authenticated REST Calls

You will need to create a `User` and generate a JWT token for them.

For now, use the Rails console to create the `User`.

    $ bin/rails console
    user = User.new email: jean@jeantessier.com, name: "Jean Tessier"
    # We have to set the password separately so it gets encrypted.
    user.password = "abcd1234"
    user.save

Once you have a user, you can get the JWT token from the `/user_token` endpoint.

    $ http \
        POST \
        :3000/user_token \
        auth:='{"email": "jean@jeantessier.com", "password": "abcd1234"}'

And you'll get a response that looks like:

    {
        "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NzMxNjYxNjksInN1YiI6MSwiaWF0IjoxNTczMDc5NzY5LCJpc3MiOiJodHRwOi8vZ2l0aHViLmNvbS9qZWFudGVzc2llci9ib29rLXJldmlld3MiLCJuYW1lIjoiSmVhbiBUZXNzaWVyIn0.CBX6XBdbYInwTOH8fAml_-yzs83aXHjk2bhsOH3P9Pk"
    }

You can use the JWT to call protected endpoints that require authentication.

To create a book:

    $ http \
        POST \
        :3000/books \
        Authentication:"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NzMxNjYxNjksInN1YiI6MSwiaWF0IjoxNTczMDc5NzY5LCJpc3MiOiJodHRwOi8vZ2l0aHViLmNvbS9qZWFudGVzc2llci9ib29rLXJldmlld3MiLCJuYW1lIjoiSmVhbiBUZXNzaWVyIn0.CBX6XBdbYInwTOH8fAml_-yzs83aXHjk2bhsOH3P9Pk" \
        name=The_Hobbit \
        publisher="Houghton Mifflin"

Since putting the JWT on every command-line is tedious, you can tell Httpie to
fetch it from your shell's environment.

    $ pip install httpie-jwt-auth
    $ export JWT_AUTH_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NzMxNjYxNjksInN1YiI6MSwiaWF0IjoxNTczMDc5NzY5LCJpc3MiOiJodHRwOi8vZ2l0aHViLmNvbS9qZWFudGVzc2llci9ib29rLXJldmlld3MiLCJuYW1lIjoiSmVhbiBUZXNzaWVyIn0.CBX6XBdbYInwTOH8fAml_-yzs83aXHjk2bhsOH3P9Pk
    $ http --auth-type jwt POST :3000/books name=The_Hobbit publisher="Houghton Mifflin"

To update a book:

    $ http --auth-type jwt PATCH :3000/books/1 publisher="Allen & Unwin"
