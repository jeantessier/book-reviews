#!/bin/sh

function addIndex() {
  local typename=$1; shift
  local id=$1; shift
  local payload="$1"; shift

  http :4000 \
      query="mutation AddIndex(\$i: IndexInput!) {addIndex(index: \$i) {${payload}}}" \
      variables:="{\"i\": {\"typename\": \"${typename}\", \"id\": \"${id}\", \"words\": \"$*\"}}" \
      operationName=AddIndex | \
  jq --raw-output ".data.addIndex"
}

#
# User: Simon Tolkien
#

user_id=$(http :4000 \
    query='mutation AddUser($u: UserInput!) {addUser(user: $u) {userId name}}' \
    variables:="{\"u\": {\"name\": \"Simon Tolkien\", \"email\": \"simon@tolkien.com\"}}" \
    operationName=AddUser | \
jq --raw-output ".data.addUser.userId")

echo user_id $user_id

addIndex User $user_id "... on User {name}" Simon Tolkien

#
# User: Jean Tessier
#

user_id=$(http :4000 \
    query='mutation AddUser($u: UserInput!) {addUser(user: $u) {userId name}}' \
    variables:="{\"u\": {\"name\": \"Jean Tessier\", \"email\": \"jean@jeantessier.com\"}}" \
    operationName=AddUser | \
jq --raw-output ".data.addUser.userId")

echo user_id $user_id

addIndex User $user_id "... on User {name}" Jean Tessier

#
# Book: The Lord of the Rings
#

# Book

book_id=$(http :4000 \
    query='mutation AddBook($b: BookInput!) {addBook(book: $b) {bookId name}}' \
    variables:="{\"b\": {\"name\": \"The_Lord_of_the_Rings\", \"titles\": [{\"title\": \"The Lord of the Rings\", \"link\": \"https://en.wikipedia.org/wiki/The_Lord_of_the_Rings\"}], \"publisher\": \"Unwin & Allen\", \"authors\": [\"J.R.R. Tolkien\"], \"years\": [\"1954\", \"1955\"]}}" \
    operationName=AddBook | \
jq --raw-output ".data.addBook.bookId")

echo book_id $book_id

addIndex Book $book_id "... on Book {name}" lord ring Tolkien allen unwin

# Review

review_id=$(http :4000 \
    query='mutation AddReview($r: ReviewInput!) {addReview(review: $r) {reviewId book {name} user {name}}}' \
    variables:="{\"r\": {\"userId\": \"${user_id}\", \"bookId\": \"${book_id}\", \"body\": \"Awesome!\", \"start\": \"2020-05-02\", \"stop\": \"2020-05-20\"}}" \
    operationName=AddReview | \
jq --raw-output ".data.addReview.reviewId")

echo review_id $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier awesome

#
# Book: The Fellowship of the Ring
#

# Book

book_id=$(http :4000 \
    query='mutation AddBook($b: BookInput!) {addBook(book: $b) {bookId name}}' \
    variables:="{\"b\": {\"name\": \"The_Fellowship_of_the_Ring\", \"titles\": [{\"title\": \"The Fellowship of the Ring\", \"link\": \"https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring\"}], \"publisher\": \"Unwin & Allen\", \"authors\": [\"J.R.R. Tolkien\"], \"years\": [\"1954\"]}}" \
    operationName=AddBook | \
jq --raw-output ".data.addBook.bookId")

echo book_id $book_id

addIndex Book $book_id "... on Book {name}" fellowship ring Tolkien allen unwin

# Review

review_id=$(http :4000 \
    query='mutation AddReview($r: ReviewInput!) {addReview(review: $r) {reviewId book {name} user {name}}}' \
    variables:="{\"r\": {\"userId\": \"${user_id}\", \"bookId\": \"${book_id}\", \"body\": \"The Council of Elrond is a little long.!\", \"start\": \"2020-05-02\", \"stop\": \"2020-05-05\"}}" \
    operationName=AddReview | \
jq --raw-output ".data.addReview.reviewId")

echo review_id $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier council Elrond little long

#
# Book: The Two Towers
#

# Book

book_id=$(http :4000 \
    query='mutation AddBook($b: BookInput!) {addBook(book: $b) {bookId name}}' \
    variables:="{\"b\": {\"name\": \"The_Tow_Towers\", \"titles\": [{\"title\": \"The Two Towers\", \"link\": \"https://en.wikipedia.org/wiki/The_Two_Towers\"}], \"publisher\": \"Unwin & Allen\", \"authors\": [\"J.R.R. Tolkien\"], \"years\": [\"1955\"]}}" \
    operationName=AddBook | \
jq --raw-output ".data.addBook.bookId")

echo book_id $book_id

addIndex Book $book_id "... on Book {name}" two tower Tolkien allen unwin

# Review

review_id=$(http :4000 \
    query='mutation AddReview($r: ReviewInput!) {addReview(review: $r) {reviewId book {name} user {name}}}' \
    variables:="{\"r\": {\"userId\": \"${user_id}\", \"bookId\": \"${book_id}\", \"body\": \"The Battle of Helm's Deep is a little long.!\", \"start\": \"2020-05-06\", \"stop\": \"2020-05-10\"}}" \
    operationName=AddReview | \
jq --raw-output ".data.addReview.reviewId")

echo review_id $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier battle Helm Deep little long

#
# Book: The Return of the King
#

# Book

book_id=$(http :4000 \
    query='mutation AddBook($b: BookInput!) {addBook(book: $b) {bookId name}}' \
    variables:="{\"b\": {\"name\": \"The_Return_of_the_King\", \"titles\": [{\"title\": \"The Return of the King\", \"link\": \"https://en.wikipedia.org/wiki/The_Return_of_the_King\"}], \"publisher\": \"Unwin & Allen\", \"authors\": [\"J.R.R. Tolkien\"], \"years\": [\"1955\"]}}" \
    operationName=AddBook | \
jq --raw-output ".data.addBook.bookId")

echo book_id $book_id

addIndex Book $book_id "... on Book {name}" return king Tolkien allen unwin

# Review

review_id=$(http :4000 \
    query='mutation AddReview($r: ReviewInput!) {addReview(review: $r) {reviewId book {name} user {name}}}' \
    variables:="{\"r\": {\"userId\": \"${user_id}\", \"bookId\": \"${book_id}\", \"body\": \"The ending is a little long.!\", \"start\": \"2020-05-11\", \"stop\": \"2020-05-20\"}}" \
    operationName=AddReview | \
jq --raw-output ".data.addReview.reviewId")

echo review_id $review_id

addIndex Review $review_id "... on Review {body}" Jean Tessier ending little long
