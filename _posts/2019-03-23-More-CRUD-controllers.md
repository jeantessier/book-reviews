---
layout: post
title:  "More CRUD Endpoints for Book and Review"
date:   2019-03-23 12:55:00 -0700
categories: node mongodb mongoose express-jwt
---
I added a controllers for CRUD operations on `Book` and `Review` objects.  They
use JWT to authenticate and authorize the user and ensure that non-admin users
can only operate on their own data.
