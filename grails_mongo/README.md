# Grails with MongoDB

This is a Grails application backed by a MongoDB database.

These instructions assume you have installed [HTTPie](https://httpie.org/) and
the [MongoDB Shell](https://www.mongodb.com/docs/mongodb-shell/).

## MongoDB

Run MongoDB in a Docker container.

```bash
docker compose up -d
```

This command will create a new database named `grails_mongo_book_reviews` and
populate it with collections derived from `Books_????-??-??.md`.

```bash
./Books_mongo.pl > book_reviews.js
mongosh grails_mongo_book_reviews book_reviews.js
```

You can reset the database with these commands:

```bash
docker compose down
docker volume rm grails_neo4j_neo4j_data
docker compose up -d
```

## Running the Server

You can start the application with:

```bash
./gradlew bootRun
```

And point your browser to http://localhost:8080.

## Making REST Calls

To get a list of users:

```bash
http :8080/user/index.json
```

To get a list of books:

```bash
http :8080/book/index.json
```

To get the book with ID 2:

```bash
http :8080/book/show/2.json
```
