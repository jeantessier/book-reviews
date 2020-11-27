---
layout: post
title: "Use Grails with Neo4j"
date: 2020-11-26 16:10:00 -0800
categories: Grails Neo4j
---
I'm curious about using a graph database like [Neo4j](https://neo4j.com/).

I setup Neo4j using Docker.

```bash
docker run \
    --detach \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --name neo4j \
    neo4j
```

I tried to create a Grails app that would use Neo4j as its database.  By
default, it uses an embedded database, but the documentation hints that it might
conflict with some other parts.  With an embedded configuration, the server will
not start.  It complains that it can't find the dependency on `neo4j-harness`.
And with an external configuration, the server hangs during startup.

This option will require more research.
