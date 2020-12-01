---
layout: post
title: "Merge All Branches Back to Master"
date: 2020-11-30 22:19:00 -0800
categories: Git
---
I don't need to isolate all the implementations, anymore.  I can see the history
of a given implementation by constraining `git log` to its folder.  I used a
single `git merge` command that created a single merge node in the Git repo with
multiple ancestors.

```bash
git merge \
    grails_mysql \
    grails_mongo \
    grails_neo4j \
    node_mongo \
    node_graphql_federation \
    micronaut_neo4j \
    rails_mysql_graphql_user_errors
```
