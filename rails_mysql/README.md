# Rails with MySQL

This is a Ruby on Rails application backed by a MySQL database.

* Ruby version: `2.4.3`
* Rails version: `5.0.7.2`

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

And use the base URL http://localhost:3000.

## Making REST Calls

To get a list of users:

    $ http :3000/users

To get a list of books:

    $ http :3000/books

To get the book with ID 2:

    $ http :3000/books/2
