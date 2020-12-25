# Micronaut with Neo4j

This is a Micronaut application backed by a Neo4j database.

## Neo4j

The Community edition of Neo4j does not support multiple databases, so you don't
have to worry about creating a new database.  The default database will do just
fine.

If your database already has contents and you want to get rid of them, you can
use this Cypher command:

    match ()-[r]->() delete r
    match(n) delete n

The following command will seed a database with some test data.

    $ ./seed.sh

> The `seed.sh` script assumes the server is already running and that HTTPie is
> on your `PATH`.

At this time, I don't have a clean mechanism to populate it with data derived
from `../data/Books_????-??-??.md`.

## Running the Server

You can start the application with:

    $ ./gradlew run

And point your browser to http://localhost:8080.

## Making REST Calls

to get a list of users:

    $ http :8080/users

To get a list of books:

    $ http :8080/books

To get the book with ID 2:

    $ http :8080/books/2
