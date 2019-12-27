# Book Reviews

This is a sample set of applications that show how to put book reviews in a
federated GraphQL schema.

There are four underlying services:

- `books` has per-book data
- `users` has per-user data
- `reviews` has the reviews themselves
- `search` runs the search query

These four services each define a part of overall schema.  The `gateway` service
ties them all together.
