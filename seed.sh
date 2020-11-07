#!/bin/sh

function addUser() {
  local name=$1; shift
  local email=$1; shift

  http :4000 \
    query='mutation AddUser($u: UserInput!) {addUser(user: $u) {userId}}' \
    variables:="{\"u\": {\"name\": \"${name}\", \"email\": \"${email}\"}}" \
    operationName=AddUser | \
  jq --raw-output ".data.addUser.userId"
}

function addBook() {
  local name=$1; shift
  local titles=$1; shift
  local publisher=$1; shift
  local authors=$1; shift
  local years=$1; shift

  http :4000 \
    query='mutation AddBook($b: BookInput!) {addBook(book: $b) {bookId}}' \
    variables:="{\"b\": {\"name\": \"${name}\", \"titles\": ${titles}, \"publisher\": \"${publisher}\", \"authors\": ${authors}, \"years\": ${years}}}" \
    operationName=AddBook | \
  jq --raw-output ".data.addBook.bookId"
}

function addReview() {
  local user_id=$1; shift
  local book_id=$1; shift
  local body=$1; shift
  local start=$1; shift
  local stop=$1; shift

  http :4000 \
    query='mutation AddReview($r: ReviewInput!) {addReview(review: $r) {reviewId}}' \
    variables:="{\"r\": {\"userId\": \"${user_id}\", \"bookId\": \"${book_id}\", \"body\": \"${body}\", \"start\": \"${start}\", \"stop\": \"${stop}\"}}" \
    operationName=AddReview | \
  jq --raw-output ".data.addReview.reviewId"
}

function addIndex() {
  local typename=$1; shift
  local id=$1; shift
  local payload="$1"; shift

  local indexCount=$(http :4000 \
      query="mutation AddIndex(\$i: IndexInput!) {addIndex(index: \$i) {${payload}}}" \
      variables:="{\"i\": {\"typename\": \"${typename}\", \"id\": \"${id}\", \"words\": \"$*\"}}" \
      operationName=AddIndex | \
  jq --raw-output ".data.addIndex | length")
  echo "    is in ${indexCount} indices"
}

#
# User: Simon Tolkien
#

user_id=$(addUser "Simon Tolkien" "simon@tolkien.com")

echo User $user_id

addIndex User $user_id "... on User {name}" Simon Tolkien

#
# User: Jean Tessier
#

user_id=$(addUser "Jean Tessier" "jean@jeantessier.com")

echo User $user_id

addIndex User $user_id "... on User {name}" Jean Tessier

#
# Book: The Lord of the Rings
#

# Book

book_id=$(addBook "The_Lord_of_the_Rings" "[{\"title\": \"The Lord of the Rings\", \"link\": \"https://en.wikipedia.org/wiki/The_Lord_of_the_Rings\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1954\", \"1955\"]")

echo Book $book_id

addIndex Book $book_id "... on Book {name}" lord ring Tolkien allen unwin 1954 1955

# Review

review_id=$(addReview $user_id $book_id "Awesome!" "2020-05-02" "2020-05-20")

echo Review $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier awesome

#
# Book: The Fellowship of the Ring
#

# Book

book_id=$(addBook "The_Fellowship_of_the_Ring" "[{\"title\": \"The Fellowship of the Ring\", \"link\": \"https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1954\"]")

echo Book $book_id

addIndex Book $book_id "... on Book {name}" fellowship ring Tolkien allen unwin 1954

# Review

review_id=$(addReview $user_id $book_id "The Council of Elrond is a little long." "2020-05-02" "2020-05-05")

echo Review $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier council Elrond little long

#
# Book: The Two Towers
#

# Book

book_id=$(addBook "The_Two_Towers" "[{\"title\": \"The Two Towers\", \"link\": \"https://en.wikipedia.org/wiki/The_Two_Towers\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1955\"]")

echo Book $book_id

addIndex Book $book_id "... on Book {name}" two tower Tolkien allen unwin 1955

# Review

review_id=$(addReview $user_id $book_id "The Battle of Helm's Deep is a little long." "2020-05-06" "2020-05-10")

echo Review $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier battle Helm Deep little long

#
# Book: The Return of the King
#

# Book

book_id=$(addBook "The_Return_of_the_King" "[{\"title\": \"The Return of the King\", \"link\": \"https://en.wikipedia.org/wiki/The_Return_of_the_King\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1955\"]")

echo Book $book_id

addIndex Book $book_id "... on Book {name}" return king Tolkien allen unwin 1955

# Review

review_id=$(addReview $user_id $book_id "The ending is a little long." "2020-05-11" "2020-05-20")

echo Review $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier ending little long
