---
layout: post
title: "Use GraphQL with Rails"
date: 2020-11-05 22:30:00 -0700
categories: Rails GraphQL
---
Two days ago, I started adding GraphQL support to the `rails_mysql` variation.
I started with the `graphql` gem, and then added the GraphiQL environment to try
my queries.  The application's REST endpoints support authentication using JWTs
as bearer tokens.  These must be passed in as an `Authorization` header in the
HTTP request.  But GraphiQL doesn't let me set headers.

I could use Playground instead.  There is a Ruby gem to do that, but I didn't
feel like figuring it out.  I had other work that I wanted to get to.  I already
had Playground setup with an unrelated JavaScript app, and Playground lets you
aim it at arbitrary URLs, so I used that for a bit.  I also used HTTPie, but
typing GraphQL queries on the command line is _really_ tedious.

I did all this so I could experiment with the `graphql-batch` gem.

By default, the `graphql` gem runs database queries as it traverses resolvers.
You can get a little bit of caching from the ActiveRecord layer, but that does
not help you with _N+1_ problems.  If I load a user with 100 reviews and
traverse these reviews to print the start date, ActiveRecord will make 2
database queries; one for the user and one for its reviews.  But if I decide to
follow from the review to its book to print its name, ActiveRecord will load
each book separately, making 100 new database queries in the process.

The `graphql-batch` gem provides support for batching database lookups.  As the
`graphql` gem goes through the resolvers, it will accumulate the users and
reviews and books that are accessed.  It will do its best to group these
database queries together so the result is 3 database queries instead of 102.

```sql
SELECT * FROM users WHERE id = ?;
SELECT * FROM reviews WHERE reviewer_id = ?;
SELECT * FROM books WHERE id IN (?, ?, ?, ..., ?, ?);
```

The `AssociationLoader` was particularly strange.  It relies on a side-effect in
ActiveRecord where calling `ActiveRecord::Associations::Preloader#preload` will
actually hydrate the models by loading their associated objects into them.  Not
very functional, but I got it to work.
