# Grails with MySQL

This is a Grails application backed by a Neo4j database.

## Neo4j

I don't have a command at this time to create and populate a database.

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
