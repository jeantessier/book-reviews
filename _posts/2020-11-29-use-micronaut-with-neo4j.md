---
layout: post
title: "Use Micronaut with Neo4j"
date: 2020-11-29 14:23:00 -0800
categories: Micronaut Neo4j
---
I got the Micronaut version to work with a local [Neo4j](https://neo4j.com/)
database.  I borrowed a `User` and `UserController` classes from one of my
[starter Micronaut projects](https://github.com/jeantessier/micronaut-gorm-example).

I had to downgrade Neo4j from `4.2` to `3.5` because the ORM is using a  CYPHER
syntax that is no longer valid.  It was deprecated in `3.0` and removed in
`4.0`.  I don't quite get why the drivers have not been updated.

```bash
docker run \
    --detach \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --name neo4j-3.5 \
    neo4j:3.5
```

I can `GET /users` when there are no `User` nodes.  But the moment I create one,
it starts to `500` with this error message coming from the driver:

```
Cannot access records on this result any more as the result has already
been consumed or the query runner where the result is created has
already been closed.
```

I can `POST /users` and `GET /users/<id>` and `DELETE /users/<id>` just fine.

Next, I'll need to get relationships working and see if I can coax it to use
UUIDs instead of Neo4j's internal numerical IDs.
