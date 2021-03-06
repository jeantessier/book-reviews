#!/bin/bash

#
# You can wipe the database clean with:
#     echo "match ()-[r]->() delete r; match(n) delete n;" | docker exec -i neo4j-3.5 cypher-shell -u neo4j -p abcd1234
#

readonly ENDPOINT=:8080

function addUser() {
  local name=$1; shift
  local email=$1; shift

  http \
    $ENDPOINT/users \
    name="$name" \
    email=$email \
    password=abcd1234 | \
  jq --raw-output ".id"
}

function addBook() {
  local name=$1; shift
  local titles=$1; shift
  local publisher=$1; shift
  local authors=$1; shift
  local years=$1; shift

  http \
    $ENDPOINT/books \
    name=$name \
    titles:="$titles" \
    publisher="$publisher" \
    authors:="$authors" \
    years:="$years" | \
  jq --raw-output ".id"
}

function addReview() {
  local reviewer_id=$1; shift
  local book_id=$1; shift
  local body=$1; shift
  local start=$1; shift
  local stop=$1; shift

  if [[ $start ]]
  then
    if [[ $stop ]]
    then
      http \
        $ENDPOINT/reviews/user/${reviewer_id}/book/${book_id} \
        body="$body" \
        start=$start \
        stop=$stop | \
      jq --raw-output ".type"
    else
      http \
        $ENDPOINT/reviews/user/${reviewer_id}/book/${book_id} \
        body="$body" \
        start=$start | \
      jq --raw-output ".type"
    fi
  else
    if [[ $stop ]]
    then
      http \
        $ENDPOINT/reviews/user/${reviewer_id}/book/${book_id} \
        body="$body" \
        stop=$stop | \
      jq --raw-output ".type"
    else
      http \
        $ENDPOINT/reviews/user/${reviewer_id}/book/${book_id} \
        body="$body" | \
      jq --raw-output ".type"
    fi
  fi
}

#
# User: Jean Tessier
#

jean_id=$(addUser "Jean Tessier" "jean@jeantessier.com")

echo User $jean_id

#
# User: Simon Tolkien
#

simon_id=$(addUser "Simon Tolkien" "simon@tolkien.com")

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
