#!/bin/bash

#
# Requires the Neo4j Cypher Shell to be on our $PATH.
#
# You can download it from Neo4j:
#   https://neo4j.com/deployment-center/?cypher#tools-tab
#



#
# Users
#



cypher-shell \
    --param '{reviewer1: {name: "Jean Tessier", email: "jean@jeantessier.com", password: "abcd1234"}}' \
    --param '{reviewer2: {name: "Simon Tolkien", email: "simon@tolkien.com", password: "abcd1234"}}' <<-'EOF'
    create
      (reviewer1:User $reviewer1),
      (reviewer2:User $reviewer2)
    return *
EOF


#
# Books & Reviews
#



# The Hobbit

cypher-shell \
    --param '{reviewer1: "jean@jeantessier.com"}' \
    --param '{reviewer2: "simon@tolkien.com"}' \
    --param '{book: {name: "The_Hobbit", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1937]}}' \
    --param '{title1: {title: "The Hobbit", link: "https://en.wikipedia.org/wiki/The_Hobbit"}}' \
    --param '{title2: {title: "Bilbo le Hobbit", link: "https://fr.wikipedia.org/wiki/Le_Hobbit"}}' \
    --param '{review1: {body: "Awesome!", start: "2020-05-02", stop: "2020-05-20"}}' \
    --param '{review2: {body: "Reminds me of when I was a kid.", start: "2020-05-01", stop: "2020-05-01"}}' <<-'EOF'
    match
      (reviewer1:User {email: $reviewer1}),
      (reviewer2:User {email: $reviewer2})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title1),
      (b)-[:TITLE]->(:Title $title2),
      (b)<-[:BOOK]-(:Review $review1)-[:REVIEWER]->(reviewer1),
      (b)<-[:BOOK]-(:Review $review2)-[:REVIEWER]->(reviewer2)
    return b
EOF



# The Lord of the Rings

cypher-shell \
    --param '{reviewer: "jean@jeantessier.com"}' \
    --param '{book: {name: "The_Lord_of_the_Rings", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1954, 1955]}}' \
    --param '{title: {title: "The Lord of the Rings", link: "https://en.wikipedia.org/wiki/The_Lord_of_the_Rings"}}' \
    --param '{review: {body: "Awesome!", start: "2020-05-02", stop: "2020-05-20"}}' <<-'EOF'
    match
      (reviewer:User {email: $reviewer})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title),
      (b)<-[:BOOK]-(:Review $review)-[:REVIEWER]->(reviewer)
    return b
EOF



# The Fellowship of the Ring

cypher-shell \
    --param '{reviewer: "jean@jeantessier.com"}' \
    --param '{book: {name: "The_Fellowship_of_the_Ring", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1954]}}' \
    --param '{title: {title: "The Fellowship of the Ring", link: "https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring"}}' \
    --param '{review: {body: "The Council of Elrond is a little long.", start: "2020-05-02", stop: "2020-05-05"}}' <<-'EOF'
    match
      (reviewer:User {email: $reviewer})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title),
      (b)<-[:BOOK]-(:Review $review)-[:REVIEWER]->(reviewer)
    return b
EOF



# The Two Towers

cypher-shell \
    --param '{reviewer: "jean@jeantessier.com"}' \
    --param '{book: {name: "The_Two_Towers", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1955]}}' \
    --param '{title: {title: "The Two Towers", link: "https://en.wikipedia.org/wiki/The_Two_Towers"}}' \
    --param '{review: {body: "The Battle of Helm'\''s Deep is a little long.", start: "2020-05-06", stop: "2020-05-10"}}' <<-'EOF'
    match
      (reviewer:User {email: $reviewer})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title),
      (b)<-[:BOOK]-(:Review $review)-[:REVIEWER]->(reviewer)
    return b
EOF



# The Return of the King

cypher-shell \
    --param '{reviewer: "jean@jeantessier.com"}' \
    --param '{book: {name: "The_Return_of_the_King", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1955]}}' \
    --param '{title: {title: "The Return of the King", link: "https://en.wikipedia.org/wiki/The_Return_of_the_King"}}' \
    --param '{review: {body: "The ending is a little long.", start: "2020-05-11", stop: "2020-05-20"}}' <<-'EOF'
    match
      (reviewer:User {email: $reviewer})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title),
      (b)<-[:BOOK]-(:Review $review)-[:REVIEWER]->(reviewer)
    return b
EOF



# The Silmarillion

cypher-shell \
    --param '{reviewer1: "jean@jeantessier.com"}' \
    --param '{reviewer2: "simon@tolkien.com"}' \
    --param '{book: {name: "The_Silmarillion", authors: ["Christopher Tolkien", "J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1977]}}' \
    --param '{title: {title: "The Silmarillion", link: "https://en.wikipedia.org/wiki/The_Silmarillion"}}' \
    --param '{review1: {body: "Epic!", start: "2020-05-21", stop: "2020-05-30"}}' \
    --param '{review2: {body: "Bacon!", start: "2019-12-11", stop: "2019-12-20"}}' <<-'EOF'
    match
      (reviewer1:User {email: $reviewer1}),
      (reviewer2:User {email: $reviewer2})
    create
      (b:Book $book),
      (b)-[:TITLE]->(:Title $title),
      (b)<-[:BOOK]-(:Review $review1)-[:REVIEWER]->(reviewer1),
      (b)<-[:BOOK]-(:Review $review2)-[:REVIEWER]->(reviewer2)
    return b
EOF



#
# End of File
#
