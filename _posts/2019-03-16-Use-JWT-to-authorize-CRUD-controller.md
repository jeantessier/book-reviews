---
layout: post
title:  "Use JWT to Authorize CRUD Endpoint for User"
date:   2019-03-16 20:55:00 -0700
categories: node mongodb mongoose express-jwt
---
I added a controller for CRUD operations on `User` objects.  It uses JWT to
authenticate and authorize the user.  Read-only operations are open to everyone,
but read-write operations are limited to admin users.

This was an opportunity to refactor `app_api/routes/index.js` to separate
authentication-related endpoints, `/api/register` and `/api/login`, from the
user-related endpoints and place each group in its own routing file.
