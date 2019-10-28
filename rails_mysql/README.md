# Rails with MySQL

This is a Ruby on Rails application backed by a MySQL database.

## MySQL

This command will create a new database named `rails_mysql_book_reviews` and
populate it with data derived from `../data/Books_????-??-??.txt`.

    $ ./Books_rails_mysql.pl | mysql -u root

## Running the Tests

You can run all the tests with:

    $ bundle exec rspec

## Running the Server

You can start the application with:

    $ ./bin/rails server

And point your browser to http://localhost:3000.

## Making REST Calls

to get a list of users:

    $ curl http://localhost:3000/user/index.json

To get a list of books:

    $ curl http://localhost:3000/book/index.json

To get the book with ID 2:

    $ curl http://localhost:3000/book/show/2.json
