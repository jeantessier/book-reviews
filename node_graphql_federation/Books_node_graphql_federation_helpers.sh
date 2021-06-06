#!/bin/sh

#
# Global Constants
#

readonly GRAPHQL_ENDPOINT=:4000

# Forged admin credentials: { "roles": ["ROLE_ADMIN"] }
export JWT_AUTH_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlcyI6WyJST0xFX0FETUlOIl19.PSTChvPnRFYmQZtBPHX0rzusrYa6ori9z1d1n0LsF8g

#
# Helper Functions
#

function addUser() {
  local name=$1; shift
  local email=$1; shift
  local password=$1; shift
  local roles=$1; shift

  http --ignore-stdin --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddUser($u: AddUserInput!) {addUser(user: $u) {id}}' \
    variables:="{\"u\": {\"name\": \"${name}\", \"email\": \"${email}\"}, \"password\": \"${password}\", \"roles\": [${roles}]}}" \
    operationName=AddUser | \
  jq --raw-output ".data.addUser.id"
}

function addBook() {
  local name=$1; shift
  local titles=$1; shift
  local publisher=$1; shift
  local authors=$1; shift
  local years=$1; shift

  http --ignore-stdin --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddBook($b: AddBookInput!) {addBook(book: $b) {id}}' \
    variables:="{\"b\": {\"name\": \"${name}\", \"titles\": ${titles}, \"publisher\": \"${publisher}\", \"authors\": ${authors}, \"years\": ${years}}}" \
    operationName=AddBook | \
  jq --raw-output ".data.addBook.id"
}

function addReview() {
  local reviewer_id=$1; shift
  local book_id=$1; shift
  local body=$1; shift
  local start=$1; shift
  local stop=$1; shift

  http --ignore-stdin --auth-type jwt $GRAPHQL_ENDPOINT \
    query='mutation AddReview($r: AddReviewInput!) {addReview(review: $r) {id}}' \
    variables:="{\"r\": {\"reviewerId\": \"${reviewer_id}\", \"bookId\": \"${book_id}\", \"body\": \"${body}\", \"start\": \"${start}\", \"stop\": \"${stop}\"}}" \
    operationName=AddReview | \
  jq --raw-output ".data.addReview.id"
}
