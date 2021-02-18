# Grails with MongoDB

This is a Grails application backed by a MongoDB database.

## MongoDB

This command will create a new database named `grails_mongo_book_reviews` and
populate it with collections derived from `Books_????-??-??.md`.

    $ ./Books_mongo.pl > book_reviews.js
    $ mongo grails_mongo_book_reviews book_reviews.js

## Running the Server

You can start the application with:

    $ ./gradlew bootRun

And point your browser to http://localhost:8080.

## Making REST Calls

To get a list of users:

    $ curl http://localhost:8080/user/index.json

To get a list of books:

    $ curl http://localhost:8080/book/index.json

To get the book with ID 2:

    $ curl http://localhost:8080/book/show/2.json
