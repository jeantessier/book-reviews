---
layout: post
title:  "Fixed Mongoose Integration in Node with MongoDB"
date:   2019-03-13 21:38:00 -0700
categories: node mongodb mongoose
---
Updated and fixed Passport integration.

Somehow, encoding passwords was never returning.  I had to do a lot of back and
forth to get it working again.

Changed the password encoding algorithm to stronger encoding, and save them as
base-64-encoded instead of hexadecimal.

Added a `/api/resetPassword` endpoint so I can overwrite the bogus `salt` and
`hash` that I hardcoded in the user generation script.

Brought the style closer to ES6, such as using arrow functions and moving away
from `var` variables.

Changed `password` to `hash` in the database schema.
