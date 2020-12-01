---
layout: post
title: "Neo4j Relationships in Micronaut"
date: 2020-11-30 22:09:00 -0800
categories: Micronaut Neo4j
---
I followed the GORM documentation to setup a `REVIEW` relationship between my
`User` and `Book` nodes.  I'm able to create these relationships, but I'm not
able to look them up once they are created.  And if I put them as `hasMany`
associations on the entity classes, GORM is no longer able to load them from the
database, anymore.

I had to revert my use of UUIDs as primary IDs.  GORM is generating search
queries that use Neo4j's`ID()` function to match entities.  This function
returns Neo4j's internal numerical ID, not the entity's UUID (whether it was
called `id` or `uuid`).
