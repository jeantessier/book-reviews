---
layout: post
title:  "Added Roles to Node with MongoDB"
date:   2019-03-16 11:25:00 -0700
categories: node mongodb mongoose
---
The Node app was broken again.  Turns out I was a little overeager in changing
functions to arrow functions.  It messed up with `this` in model methods.

I also reworked the claims in the JWT.  I replaced `_id` with the registered
claim `sub`.  I also added roles to the `User` model, similar to those in
Spring Security, and a I added a private claim `admin` in the JWT to tell if
the user has admin privileges.
