---
layout: post
title: "Tighten Up MongoDB Queries"
date: 2021-12-29 12:15:00 -0800
categories: node mongodb mongoose
---
When the Node w/ MongoDB variation shows a `User`, it also shows their `salt`
and `hash` fields.  This could be a security concern and I was looking for a way
to exclude these fields.  When writing a MongoDB query by hand, you can specify
which fields you're interested in.  But I'm using Mongoose as a layer between
the application and the database, and I wanted to find out what support it might
have for these _projections_.

I can pass the raw _projection_ in the calls to Mongoose:

```javascript
User.find({}, { salt: -1, hash: -1 })
```

But Mongoose also supports a string version for it:

```javascript
User.find({}, "-salt -hash")
```

The [Mongoose documentation](https://mongoosejs.com/docs/queries.html) mentions
[Query.select()](https://mongoosejs.com/docs/api.html#query_Query-select).  I
find this last form a nice mix of simpler Mongoose notation while not as cryptic
as an unnamed second parameter.

```javascript
User.find({}).select("-salt -hash")
```

This works fine for queries, but what about mutations?  When I create or update
a `User`, I get the full object back.  I looked for a simple way to filter out
the `salt` and `hash` fields.  In the end, I had to rely on a global Express
setting named `json replacer` to redact these fields on **all** rendered JSON.
