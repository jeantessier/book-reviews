# Protocol Buffers

This folder attempts to model book reviews as protocol buffers.

## Generate Language-Specific Protocol Buffer Code

### Ruby

```bash
mkdir ruby
protoc --ruby_out ruby book_reviews.proto
```

Install the `google-protobuf` library:

```bash
gem install google-protobuf
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
user = BookReviews::User.new name: 'Jean Tessier', email: 'jean@jeantessier.com', password: 'abcd1234', roles: [ :ROLE_USER, :ROLE_ADMIN ]
user.id = SecureRandom.uuid

encoded_user = BookReviews::User.encode user
File.write 'user.data', encoded_user


# Create a review
review = BookReviews::Review.new reviewer: user, book: book, body: 'Awesome!'
review.id = SecureRandom.uuid
start = Date.parse('2022-06-04')
review.start = Google::Protobuf::Timestamp.new seconds: start.to_time.to_i, nanos: start.to_time.nsec
File.write 'review.data', BookReviews::Review.encode(review)

# Technically, nanos on dates are always 0, so we can rewrite the start as:
# review.start = Google::Protobuf::Timestamp.new seconds: Date.parse('2022-06-04').to_time.to_i


# Read a user from a protobuf
decoded_user = BookReviews::User.decode encoded_user
```

File I/O with a serialized protobuf:

```ruby
require './ruby/book_reviews_pb'

# Write the user to a binary protobuf in a file
File.write 'user.data', BookReviews::User.encode(user)

# Read a user from a binary protobuf
user = nil
File.open 'user.data' do |f|
  user = BookReviews::User.decode f.read
end
```

File I/O with a JSON protobuf:

```ruby
require './ruby/book_reviews_pb'

# Write the user to a binary protobuf in a file
File.write 'user.json', BookReviews::User.encode_json(user)

# Read a user from a binary protobuf
user = nil
File.open 'user.json' do |f|
  user = BookReviews::User.decode_json f.read
end
```

### Bash

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

You will need JAR files for:
- `com.google.protobuf:protobuf-java`
- `com.google.protobuf:protobuf-java-util`
- `com.google.code.gson:gson`

Copy them to `java/lib`.
Add them to your `CLASSPATH` for convenience.

```bash
for f in java/lib/* java/classes
do
    export CLASSPATH=$f:$CLASSPATH
done
```

To compile the protobuf classes:

```bash
mkdir java/classes
javac -d java/classes java/book_reviews/BookReviews.java
```

To create entities in Java:

```java
import com.google.protobuf.Timestamp;
import book_reviews.BookReviews;

# Create a book with two titles
BookReviews.Book book = BookReviews.Book
    .newBuilder()
    .setId(UUID.randomUUID() as String)
    .setName("The_Hobbit")
    .addAuthors("J.R.R. Tolkien")
    .addYears("1937")
    .setPublisher("Allen & Unwin")
    .addTitles(
        BookReviews.Book.Title
	    .newBuilder()
	    .setTitle("The Hobbit")
	    .setLink("https://en.wikipedia.org/wiki/The_Hobbit")
    )
    .addTitles(
        BookReviews.Book.Title
	    .newBuilder()
	    .setTitle("Bilbo, le hobbit")
    )
    .build();

# Create a user
BookReviews.User user = BookReviews.User
    .newBuilder()
    .setId(UUID.randomUUID() as String)
    .setName("Jean Tessier")
    .setEmail("jean@jeantessier.com")
    .setPassword("abcd1234")
    .addRoles("ROLE_USER")
    .addRoles("ROLE_ADMIN")
    .build();

# Create a review
BookReviews.Review review = BookReviews.Review
    .newBuilder()
    .setId(UUID.randomUUID() as String)
    .setReviewer(user)
    .setBook(book)
    .setBody("Awesome!")
    .setStart(Timestamp.fromMillis(System.currentTimeMillis()))
    .build();
```

To create entities in Groovy:

```groovy
import com.google.protobuf.util.Timestamps
import book_reviews.BookReviews

# Create a book with two titles
book_builder = BookReviews.Book.newBuilder()
book_builder.id = UUID.randomUUID() as String
book_builder.name = "The_Hobbit"
book_builder.addAuthors "J.R.R. Tolkien"
book_builder.addYears "1937"
book_builder.publisher = "Allen & Unwin"

title_builder = BookReviews.Book.Title.newBuilder()

title_builder.title = "The Hobbit"
title_builder.link = "https://en.wikipedia.org/wiki/The_Hobbit"
book_builder.addTitles(title_builder)

title_builder.title = "Bilbo, le hobbit"
title_builder.clearLink()
book_builder.addTitles(title_builder)

book = book_builder.build()

# Create a user
user_builder = BookReviews.User.newBuilder()
user_builder.id = UUID.randomUUID() as String
user_builder.name = "Jean Tessier"
user_builder.email = "jean@jeantessier.com"
user_builder.password = "abcd1234"
user_builder.addRoles "ROLE_USER"
user_builder.addRoles "ROLE_ADMIN"
user = user_builder.build()

# Create a review
review_builder = BookReviews.Review.newBuilder()
review_builder.id = UUID.randomUUID() as String
review_builder.reviewer = user
review_builder.book = book
review_builder.body = "Awesome!"
review_builder.start = Timestamps.fromMillis System.currentTimeMillis()
review = review_builder.build();
```

File I/O with a serialized protobuf:

```java
import java.io.FileInputStream;
import java.io.FileOutputStream;
import book_reviews.BookReviews;

# Write the user to a binary protobuf in a file
try (FileOutputStream output = new FileOutputStream("user.data")) {
    user.writeTo(output);
}

# Read a user from a binary protobuf
BookReviews.User user = BookReviews.User.parseFrom(new FileInputStream("user.data"));
```

File I/O with a JSON protobuf:

```java
import java.io.FileReader;
import java.io.FileWriter;
import com.google.protobuf.util.JsonFormat;
import book_reviews.BookReviews;

# Write the user to a JSON protobuf in a file
JsonFormat.Printer printer = JsonFormat.printer();
try (FileWriter writer = new FileWriter("user.json")) {
    writer.print(printer.print(user));
}

# Read a user from a JSON protobuf
JsonFormat.Parser parser = JsonFormat.parser();
BookReviews.User.Builder builder = BookReviews.User.newBuilder();
try (FileReader reader = new FileReader("user.json")) {
    parser.merge(reader, builder);
}
BookReviews.User user = builder.build();
```

File I/O with a text protobuf:

```java
import java.io.FileReader;
import java.io.FileWriter;
import book_reviews.BookReviews;

# Write the user to a text protobuf in a file
try (FileWriter writer = new FileWriter("user.json")) {
    writer.print(user.toString());
}

# Read a user from a JSON protobuf
# TBD
```

### Python

```bash
mkdir python
protoc --python_out python book_reviews.proto
```

Install the `protobuf` library:

```bash
pip3 install protobuf
```

Create a user:

```python
import uuid
import python.book_reviews_pb2 as book_reviews

# Create a user
user = book_reviews.User()
user.id = str(uuid.uuid4())
user.name = "Jean Tessier"
user.email = "jean@jeantessier.com"
user.password = "abcd1234"
user.roles.append("ROLE_USER")
user.roles.append("ROLE_ADMIN")
```

File I/O with a serialized protobuf:

```python
import python.book_reviews_pb2 as book_reviews

# Write the user to a binary protobuf in a file
with open("user.data", "wb") as f:
    f.write(user.SerializeToString())

# Read a user from a binary protobuf
decoded_user = book_reviews.User()
with open("user.data", "rb") as f:
    decoded_user.ParseFromString(f.read())
```

File I/O with a text protobuf:

```python
from google.protobuf import text_format

import python.book_reviews_pb2 as book_reviews

# Write the user to a text protobuf in a file
with open("user.txt", "w") as f:
f.write(text_format.MessageToString(user))

# Read a user from a text protobuf
read_user = book_reviews.User()
with open("user.txt") as f:
    text_format.Parse(f.read(), read_user)
```
