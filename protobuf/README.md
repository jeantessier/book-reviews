# Protocol Buffers

This folder attempts to model book reviews as protocol buffers.

## Generate Language-Specific Protocol Buffer Code

### Ruby

```bash
mkdir ruby
protoc --ruby_out ruby book_reviews.proto
```

You can then use it with:

```ruby
require 'securerandom'
require './ruby/book_reviews_pb'


# Create a book with two titles
book = BookReviews::Book.new(
    id: SecureRandom.uuid,
    name: :The_Hobbit,
    authors: [ 'J.R.R. Tolkien' ],
    years: [ '1937' ],
    publisher: 'Allen & Unwin',
    titles: [
        BookReviews::Book::Title.new(title: 'The Hobbit', link: 'https://en.wikipedia.org/wiki/The_Hobbit'),
        BookReviews::Book::Title.new(title: 'Bilbo, le hobbit'),
    ]
)
File.write 'book.data', BookReviews::Book.encode(book)


# Create a user
user = BookReviews::User.new name: 'Jean Tessier', email: 'jean@arbo.works', password: 'abcd1234', roles: [ :ROLE_ADMIN ]
user.id = SecureRandom.uuid

encoded_user = BookReviews::User.encode user
File.write 'user.data', encoded_user


# Create a review
review = BookReviews::Review.new reviewer: user, book: book, body: 'Awesome!'
start = Date.parse('2022-06-04')
review.start = Google::Protobuf::Timestamp.new seconds: start.to_time.to_i, nanos: start.to_time.nsec
File.write 'review.data', BookReviews::Review.encode(review)

# Technically, nanos on dates are always 0, so we can rewrite the start as:
# review.start = Google::Protobuf::Timestamp.new seconds: Date.parse('2022-06-04').to_time.to_i


# Read a user from a protobuf
decoded_user = BookReviews::User.decode encoded_user
```

```bash
protoc --decode book_reviews.Book book_reviews.proto < book.data
protoc --decode book_reviews.User book_reviews.proto < user.data
```

```bash
protoc --decode_raw < book.data
protoc --decode_raw < user.data
```

### Java

```bash
mkdir java
protoc --java_out java book_reviews.proto
```
