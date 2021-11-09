#!/bin/sh

readonly GRAPHQL_ENDPOINT=:3000

# Forged admin credentials: { "roles": ["ROLE_ADMIN"] }
export JWT_AUTH_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlcyI6WyJST0xFX0FETUlOIl19.PSTChvPnRFYmQZtBPHX0rzusrYa6ori9z1d1n0LsF8g

function addUser() {
  local name=$1; shift
  local email=$1; shift
  local password=$1; shift
  local roles=$1; shift

  http --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddUser($input: AddUserInput!) {addUser(input: $input) {user {id}}}' \
    variables:="{\"input\": {\"name\": \"${name}\", \"email\": \"${email}\", \"password\": \"${password}\", \"roles\": [${roles}]}}" \
    operationName=AddUser | \
  jq --raw-output ".data.addUser.user.id"
}

function addBook() {
  local name=$1; shift
  local titles=$1; shift
  local publisher=$1; shift
  local authors=$1; shift
  local years=$1; shift

  http --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddBook($input: AddBookInput!) {addBook(input: $input) {book {id}}}' \
    variables:="{\"input\": {\"name\": \"${name}\", \"titles\": ${titles}, \"publisher\": \"${publisher}\", \"authors\": ${authors}, \"years\": ${years}}}" \
    operationName=AddBook | \
  jq --raw-output ".data.addBook.book.id"
}

function addReview() {
  local reviewer_id=$1; shift
  local book_id=$1; shift
  local body=$1; shift
  local start=$1; shift
  local stop=$1; shift

  http --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddReview($input: AddReviewInput!) {addReview(input: $input) {review {id}}}' \
    variables:="{\"input\": {\"reviewerId\": \"${reviewer_id}\", \"bookId\": \"${book_id}\", \"body\": \"${body}\", \"start\": \"${start}\", \"stop\": \"${stop}\"}}" \
    operationName=AddReview | \
  jq --raw-output ".data.addReview.review.id"
}

#
# User: Administrator
#

admin_id=$(addUser "Administrator" "admin@bookreviews.com" "abcd1234" '"ROLE_ADMIN", "ROLE_USER"')
echo User $admin_id

#
# User: Jean Tessier
#

jean_id=$(addUser "Jean Tessier" "jean@jeantessier.com" "abcd1234" '"ROLE_USER"')

echo User $jean_id

#
# User: Simon Tolkien
#

simon_id=$(addUser "Simon Tolkien" "simon@tolkien.com" "abcd1234" '"ROLE_USER"')

echo User $simon_id

#
# Book: The Hobbit
#

# Book

book_id=$(addBook "The_Hobbit" "[{\"title\": \"The Hobbit\", \"link\": \"https://en.wikipedia.org/wiki/The_Hobbit\"}, {\"title\": \"Bilbo le Hobbit\", \"link\": \"https://fr.wikipedia.org/wiki/Le_Hobbit\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1937\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "Awesome!" "2020-05-02" "2020-05-20")

echo Review $review_id

# Review

review_id=$(addReview $simon_id $book_id "Reminds me of when I was a kid." "2020-05-01" "2020-05-01")

echo Review $review_id

#
# Book: The Lord of the Rings
#

# Book

book_id=$(addBook "The_Lord_of_the_Rings" "[{\"title\": \"The Lord of the Rings\", \"link\": \"https://en.wikipedia.org/wiki/The_Lord_of_the_Rings\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1954\", \"1955\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "Awesome!" "2020-05-02" "2020-05-20")

echo Review $review_id

#
# Book: The Fellowship of the Ring
#

# Book

book_id=$(addBook "The_Fellowship_of_the_Ring" "[{\"title\": \"The Fellowship of the Ring\", \"link\": \"https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1954\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "The Council of Elrond is a little long." "2020-05-02" "2020-05-05")

echo Review $review_id

#
# Book: The Two Towers
#

# Book

book_id=$(addBook "The_Two_Towers" "[{\"title\": \"The Two Towers\", \"link\": \"https://en.wikipedia.org/wiki/The_Two_Towers\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1955\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "The Battle of Helm's Deep is a little long." "2020-05-06" "2020-05-10")

echo Review $review_id

#
# Book: The Return of the King
#

# Book

book_id=$(addBook "The_Return_of_the_King" "[{\"title\": \"The Return of the King\", \"link\": \"https://en.wikipedia.org/wiki/The_Return_of_the_King\"}]" "Unwin & Allen" "[\"J.R.R. Tolkien\"]" "[\"1955\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "The ending is a little long." "2020-05-11" "2020-05-20")

echo Review $review_id

#
# Book: The Silmarillion
#

# Book

book_id=$(addBook "The_Silmarillion" "[{\"title\": \"The Silmarillion\", \"link\": \"https://en.wikipedia.org/wiki/The_Silmarillion\"}]" "Unwin & Allen" "[\"Christopher Tolkien\", \"J.R.R. Tolkien\"]" "[\"1977\"]")

echo Book $book_id

# Review

review_id=$(addReview $jean_id $book_id "Epic!" "2020-05-21" "2020-05-30")

echo Review $review_id

# Review

review_id=$(addReview $simon_id $book_id "Bacon!" "2019-12-11" "2019-12-20")

echo Review $review_id
