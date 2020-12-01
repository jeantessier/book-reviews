---
layout: post
title: "Use Grails with Neo4j"
date: 2020-12-01 01:23:00 -0800
categories: Grails Neo4j
---
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

After that, things mostly worked as advertised.  Mostly.
