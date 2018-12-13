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
