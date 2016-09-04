---
layout: post
title:  "User Model in Node with MongoDB"
date:   2016-09-03 16:05:00 -0700
categories: node mongodb mongoose jwt
---
Added Passport and JWT plugins to the basic Node app.  Again, I mostly copied
the boilerplate from the book "Getting MEAN".

Next, I will need to implement the rest of the schema and figure out how to use
Mongoose so that entities in one collection can reference entities in other
collections.  Once that is in place, I will be able to write a simple REST api
to access and manipulate `Book`, `Review`, and `User` objects.
