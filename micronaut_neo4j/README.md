# Micronaut with Neo4j

This is a Micronaut application backed by a Neo4j database.

These instructions assume you have installed [HTTPie](https://httpie.org/)
and Neo4j's [Cypher Shell](https://neo4j.com/deployment-center/?cypher#tools-tab).

## Neo4j

Run Neo4j in a Docker container.

```bash
docker compose up -d
```

The Community edition of Neo4j does not support multiple databases, so you don't
have to worry about creating a new database.  The default database will do just
fine.

If your database already has contents, and you want to get rid of them, you can
use this Cypher command:

    match ()-[r]->() delete r
    match(n) delete n

The following command will seed a database with some test data.

```bash
./seed.sh
```

> The `seed.sh` script assumes the server is already running and that HTTPie is
> on your `PATH`.

At this time, I don't have a clean mechanism to populate it with data derived
from `../data/Books_????-??-??.md`.

You can reset the database with these commands:

```bash
docker compose down
docker volume rm micronaut_neo4j_neo4j_data
docker compose up -d
```

## Running the Server

You can start the application with:

```bash
./gradlew run
```

And point your browser to http://localhost:8080.

## Making REST Calls

To get a list of users:

```bash
http :8080/users
```

To get a list of books:

```bash
http :8080/books
```

To get the book with ID 2:

```bash
http :8080/books/2
```
