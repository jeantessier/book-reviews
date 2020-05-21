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

## Running It

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
for service in books reviews users search
do
    (cd service; npm start &)
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
