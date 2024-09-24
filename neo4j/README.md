# Neo4j

Running Neo4j graph databsase in a Docker container.
Data is saved in a Docker volume.

```bash
docker compose up -d
```

You can reset the database with these commands:

```bash
docker compose down
docker volume rm neo4j_neo4j_data
docker compose up -d
```

These instructions assume you have Neo4j running _without authentication_ at: 
http://localhost:7474

They also assume you have installed [HTTPie](https://httpie.org/) and Neo4j's
[Cypher Shell](https://neo4j.com/deployment-center/?cypher#tools-tab).

## Seed Data

There is a simple dataset consisting of reviews of Lord of the Rings books.

### Plain Cypher

The plain Cypher script is in `seed.cypher`.  You can paste it into
the interactive Cypher Shell.

```bash
cypher-shell --file seed.cyper
```

### Cypher Shell

It is better not to hard-code values directly in Cypher queries.
Look at `seed.sh` for an example that uses parameters to pass in values.

### HTTP API

A JSON version is in `seed.json` that you can pass to Neo4j's HTTP API.

```bash
http :7474/db/neo4j/tx/commit statements:=@seed.json
```

## To Clean Out

You can clear the database with:

```bash
cypher-shell 'match ()-[r]-() delete r; match (n) delete n'
```

or

```bash
http :7474/db/neo4j/tx/commit statements:='[{"statement": "match ()-[r]-() delete r"}, {"statement": "match (n) delete n"}]'
```
