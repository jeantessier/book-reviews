# Book Reviews

This is a sample set of applications that show how to put book reviews in a
federated GraphQL schema.

There are five underlying services:

![GraphQL Schemas of Individual Services](federated_schema_1.png)

- `books` has per-book data
- `users` has per-user data
- `reviews` has the reviews themselves
- `search` runs the search query
- `signatures` augments users with a fancier signature

These five services each define a part of overall schema.  The `gateway` service
ties them all together into a single, unified schema.

![Unified GraphQL Schema](federated_schema_2.png)

## Running It

### Initial Setup

Each service is a Node app.  You need to run `npm install` to fetch their
dependencies.

```bash
for service in books reviews users search signatures gateway
do
    echo '==========' $service '=========='
    (cd $service; npm install)
done
```

### Using Docker-Compose

```bash
docker-compose up -d
```

This will run each federated service nicely hidden inside a Docker network,
where each one appears as its own host, using the default HTTP port 80.  For
example, within the Docker network, the books service lives at `http://books/`.

The gateway runs inside the Docker network as its own host and using the default
HTTP port 80.  Inside the Docker network, it lives at `http://gateway`.  But it
also maps the host's port 4000 to its port 80.  This way, from outside the
Docker network, it lives at `http://localhost:4000` like a normal Node app.

### Running Them Manually

If you are not using Docker Compose, each application runs directly on the host
machine.  Since they will share the IP address, we use different port numbers to
communicate with each one.  For example, the books service lives at
`http://localhost:4001`.

#### Starting the Federated Services

```bash
for service in books reviews users search signatures
do
    echo '==========' $service '=========='
    (cd $service; npm start &)
done
```

#### Starting the Gateway

```bash
(cd gateway; npm start &)
```

The gateway lives at `http://localhost:4000` like a normal Node app.

When the gateway is running, you can update the Apollo Graph Manager.  You will
need an API key from the Apollo
[Graph Manager](https://engine.apollographql.com/).  Once you have obtained it,
copy the `.env.template` file to `.env` and put your key in the placeholder.

```bash
(cd gateway; apollo service:push)
```

### Seed Data

You can seed the system by running the `seed.sh` script in the top folder.

It creates two users:

- Jean Tessier
- Simon Tolkien

It creates four books:

- The Lord of the Rings
- The Fellowship of the Ring
- The Two Towers
- The Return of the King

With matching reviews by the Jean Tessier user.

All of these entities are indexed in the `search` service.

## Sample Queries

You can access [`Playground`](http://localhost:4000) and copy the sample queries
and their variables to the UI to call them easily.

### Searching

Here is a sample `search` query.  It shows the titles of matching books, the
bodies of macthing reviews, and the names of matching users.

```graphql
query MySearch($q: String!) {
    search(q: $q) {
        ... on Book {
            titles {
                title
            }
        }
        ... on Review {
            body
        }
        ... on User {
            name
        }
    }
}
```

If you call it with the following variables:

```json
{
  "q": "tolkien"
}
```

It will return information about the user Simon Tolkien and all four books,
because they were authored by J.R.R. Tolkien.

If you call the same query with the variables:

```json
{
  "q": "tessier"
}
```

It will return the user Jean Tessier and all four reviews, because they were
written by Jean Tessier.

If you use the variables:

```json
{
  "q": "jean tolkien"
}
```

It will return both users and all the books and reviews, because each one is
related to at least one of these words.

#### Looking Up a Specific Entity

Say you are building a page that shows a book.  How do you fetch the information
about that book in order to populate the page?

Search for its ID with this query:

```graphql
query MySearch($q: String!) {
    search(q: $q) {
        __typename
        ... on Book {
            id
            titles {
                title
            }
            authors
            reviews {
                id
                reviewer {
                    id
                    signature
                }
            }
        }
        ... on Review {
            id
            book {
                id
                titles {
                    title
                }
                authors
            }
            reviewer {
                id
                signature
            }
            body
            start
            stop
        }
        ... on User {
            id
            name
            reviews {
                id
                book {
                    id
                    titles {
                        title
                    }
                }
            }
        }
    }
}
```

If you call it the ID of an entity:

```json
{
  "q": "53d01334-37f9-45bc-85fc-06b3f8a9bbf4"
}
```

The search will return a single entry, either a `Book`, `User`, or `Review`, as
the case may be.

### Adding Content

#### Adding a Book

You can use this query to create a new book entry:

```graphql
mutation AddBook($b: BookInput!) {
    addBook(book: $b) {
        id
        name
    }
}
```

And structure the variables like this:

```json
{
  "b": {
    "name": "The_Silmarillion",
    "titles": [
      {
        "title": "The Silmarillion",
        "link": "https://en.wikipedia.org/wiki/The_Silmarillion"
      }
    ],
    "publisher": "Unwin & Allen",
    "authors": [
      "J.R.R. Tolkien",
      "Christopher Tolkien"
    ],
    "years": ["1977"]
  }
}
```

#### Indexing a Book

You use a separate mutation to add your new book to the search index:

```graphql
mutation AddIndex($i: IndexInput!) {
    addIndex(index: $i) {
        ... on Book {
            titles {
                title
            }
        }
    }
}
```

The mutation will need the `id` from the previous mutation.  You also decide
under which words to index the book.  The words are case-insensitive and they
are separated by whitespaces.

```json
{
  "i": {
    "typename": "Book",
    "id": "<book's id goes here>",
    "words": "Silmarillion silmaril saga Christopher Chris Tolkien allen unwin"
  }
}
```

#### Adding a User

You can use this query to register a new user:

```graphql
mutation AddUser($u: UserInput!) {
    addUser(user: $u) {
        id
        name
    }
}
```

And structure the variables like this:

```json
{
  "u": {
    "name": "Christopher Tolkien",
    "email": "chris@tolkien.com"
  }
}
```

#### Indexing a User

You use a separate mutation to add your new user to the search index:

```graphql
mutation AddIndex($i: IndexInput!) {
    addIndex(index: $i) {
        ... on User {
            name
        }
    }
}
```

The mutation will need the `id` from the previous mutation.  You also decide
under which words to index the user.  The words are case-insensitive and they
are separated by whitespaces.

```json
{
  "i": {
    "typename": "User",
    "id": "<user's id goes here>",
    "words": "Christopher Chris Tolkien"
  }
}
```

#### Adding a Review

You can use this query to add a new review:

```graphql
mutation AddReview($r: ReviewInput!) {
    addReview(review: $r) {
        id
        book {
            name
        }
        reviewer {
            name
        }
    }
}
```

And structure the variables like this:

```json
{
  "r": {
    "reviewerId": "<id of the reviewer goes here>",
    "bookId": "<id of the book being reviewed goes here>",
    "body": "This book is quite fascinating, so far.",
    "start": "2020-05-21"
  }
}
```

#### Indexing a Review

You use a separate mutation to add your new review to the search index:

```graphql
mutation AddIndex($i: IndexInput!) {
    addIndex(index: $i) {
        ... on Review {
            body
        }
    }
}
```

The mutation will need the `id` from the previous mutation.  You also decide
under which words to index the review.  The words are case-insensitive and they
are separated by whitespaces.

```json
{
  "i": {
    "typename": "Review",
    "id": "<review's id goes here>",
    "words": "Bob Reviewer book fascinating far"
  }
}
```