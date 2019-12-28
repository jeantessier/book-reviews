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

## Running the Services

First, start all the participating services.

```bash
for service in books reviews users search
do
    (cd service; node index.js &)
done
```

Once the services are running, you can start the gateway.

```bash
(cd gateway; node index.js &)
```

When the gateway is running, you can update the Apollo Graph Manager.

```bash
(cd gateway; apollo service:push)
```

## Sample Queries

You can access [`Playground`](http://localhost:4000) and copy these queries and
their query variables to the UI to call them easily.

```graphql
query AllBooks {
	books {
    bookId
    titles {
      title
    }
    authors
    publisher
    years
  }
}

mutation AddBook($book: BookInput) {
  addBook(book: $book) {
    bookId
    titles {
      title
    }
    authors
    publisher
    years
  }
}

query AllUsers {
	users {
    userId
    name
    email
  }
}

mutation AddUser($user: UserInput) {
  addUser(user: $user) {
    userId
    name
    email
  }
}

query AllReviews {
  reviews {
    reviewId
    user {
      name
    }
    book {
      titles {
        title
      }
      authors
      years
    }
    body
    start
    stop
  }
}

mutation AddReview($review: ReviewInput) {
  addReview(review: $review) {
    reviewId
    user {
      name
    }
    book {
      titles {
        title
      }
    }
    body
    start
    stop
  }
}

query Search {
  search {
    user {
      name
    }
    book {
      titles {
        title
      }
      authors
      years
    }
    body
    start
    stop
  }
}

mutation AddSearchResult($searchResult: AddSearchResultInput) {
  addSearchResult(searchResult: $searchResult) {
    user {
      name
    }
    book {
      titles {
        title
      }
      authors
      years
    }
    body
    start
    stop
  }
}
```

with data:

```json
{
  "user": {
	  "name": "Jean Tessier",
  	"email": "jean@jeantessier.com"
  },
  "book": {
    "name": "The_Hobbit",
    "titles": [
      { "title": "The Silmarillion" }
    ],
    "years": [ "1977" ],
    "publisher": "Allen & Unwin",
    "authors": [
      "J.R.R. Tolkien",
      "Christopher Tolkien"
    ]
  },
  "review": {
    "userId": "eee8e970-8297-44a9-8a96-9dc3cce7e2fa",
    "bookId": "91583c67-a4d3-49d3-8343-c351485fafe3",
    "body": "Asesome!!",
    "start": "2019-12-27"
  },
  "searchResult": {
    "reviewId": "80837d41-74ef-44a4-8f87-a2503e375566"
  }
}
```
