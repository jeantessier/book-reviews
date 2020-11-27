---
layout: post
title: "Use GraphQL Federation with Node"
date: 2020-11-27 13:43:00 -0800
categories: Node GraphQL Apollo Federation
---
Some time ago, I setup an example using GraphQL with Apollo Federation.  Each
entity type is in a separate Node server.  The Apollo GraphQL Gateway unites all
the partial GraphQL schemas into a cohesive schema.

But I setup this example in a completely separate repository.  I found a way to
[combine Git repositories](https://github.community/t/combining-repositories/2060/2)
so that I could move that separate repo into this one.
