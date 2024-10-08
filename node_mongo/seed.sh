#!/bin/sh

readonly API_ENDPOINT=:3000/api

# Forged admin credentials: { "admin": true }
# This value depends on JWT_SECRET for your environment.
# Pass it as an environment variable to this script.
#
#     JWT_AUTH_TOKEN=abcd...6789 ./seed.sh
#
# The script will use the value from the environment, but
# default to the value below if you don't pass one in.
export JWT_AUTH_TOKEN=${JWT_AUTH_TOKEN:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6dHJ1ZX0.8KFeahppAFH8WUxwGLLkbBAaZHF5ZKciOG5HSQ0gajo}

function addUser() {
  local name=$1; shift
  local email=$1; shift
  local password=$1; shift
  local roles=$1; shift

  http --auth-type jwt $API_ENDPOINT/user \
    name="$name" \
    email="$email" \
    password="$password" \
    roles:="[$roles]" |
  jq --raw-output "._id"
}

function addBook() {
  local name=$1; shift
  local titles=$1; shift
  local publisher=$1; shift
  local authors=$1; shift
  local years=$1; shift

  http --auth-type jwt $API_ENDPOINT/book \
    name="$name" \
    titles:="$titles" \
    publisher="$publisher" \
    authors:="$authors" \
    years:="$years" | \
  jq --raw-output "._id"
}

function addReview() {
  local reviewer_id=$1; shift
  local book_id=$1; shift
  local body=$1; shift
  local start=$1; shift
  local stop=$1; shift

  http --auth-type jwt $API_ENDPOINT/review \
    reviewer="$reviewer_id" \
    book="$book_id" \
    body="$body" \
    start="$start" \
    stop="$stop" | \
  jq --raw-output "._id"
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
