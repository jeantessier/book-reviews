# Grails with Neo4j

This is a Grails application backed by a Neo4j database.

These instructions assume you have installed [HTTPie](https://httpie.org/) 
and Neo4j's [Cypher Shell](https://neo4j.com/deployment-center/?cypher#tools-tab).

## Neo4j

Run Neo4j in a Docker container.

```bash
docker compose up -d
```

I don't have a command at this time to create and populate a database.

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
