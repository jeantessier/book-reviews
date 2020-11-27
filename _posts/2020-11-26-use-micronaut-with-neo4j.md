---
layout: post
title: "Use Micronaut with Neo4j"
date: 2020-11-26 18:02:00 -0800
categories: Micronaut Neo4j
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

I tried to create a Micronaut app that would use Neo4j as its database.  The
Neo4j-specific documentation only covers connecting to the database.  It does
not address how to have entities interact with the database.  And there are many
options, here.  There is a plugin for GORM, but the GORM documentation is very
focused on Grails and does not mention Micronaut.  It is not clear how to make
things work with Micronaut Data.  I found
[one sample project](https://jorge-aguilera.gitlab.io/mn-collatz-neo4j/), but it
does not show all the code and it does not have a public repo, either. 

This option will require more research.
