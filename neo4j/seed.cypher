/*
 * Users
 */



create
  (reviewer1:User {name: "Jean Tessier", email: "jean@jeantessier.com", password: "abcd1234"}),
  (reviewer2:User {name: "Simon Tolkien", email: "simon@tolkien.com", password: "abcd1234"})
return *;



/*
 * Books & Reviews
 */



// The Hobbit

match
  (reviewer1:User {email: "jean@jeantessier.com"}),
  (reviewer2:User {email: "simon@tolkien.com"})
create
  (b:Book {name: "The_Hobbit", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1937]}),
  (b)-[:TITLE]->(:Title {title: "The Hobbit", link: "https://en.wikipedia.org/wiki/The_Hobbit"}),
  (b)-[:TITLE]->(:Title {title: "Bilbo le Hobbit", link: "https://fr.wikipedia.org/wiki/Le_Hobbit"}),
  (b)<-[:BOOK]-(:Review {body: "Awesome!", start: "2020-05-02", stop: "2020-05-20"})-[:REVIEWER]->(reviewer1),
  (b)<-[:BOOK]-(:Review {body: "Reminds me of when I was a kid.", start: "2020-05-01", stop: "2020-05-01"})-[:REVIEWER]->(reviewer2)
return b;



// The Lord of the Rings

match
  (reviewer:User {email: "jean@jeantessier.com"})
create
  (b:Book {name: "The_Lord_of_the_Rings", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1954, 1955]}),
  (b)-[:TITLE]->(:Title {title: "The Lord of the Rings", link: "https://en.wikipedia.org/wiki/The_Lord_of_the_Rings"}),
  (b)<-[:BOOK]-(:Review {body: "Awesome!", start: "2020-05-02", stop: "2020-05-20"})-[:REVIEWER]->(reviewer)
return b;



// The Fellowship of the Ring

match
  (reviewer:User {email: "jean@jeantessier.com"})
create
  (b:Book {name: "The_Fellowship_of_the_Ring", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1954]}),
  (b)-[:TITLE]->(:Title {title: "The Fellowship of the Ring", link: "https://en.wikipedia.org/wiki/The_Fellowship_of_the_Ring"}),
  (b)<-[:BOOK]-(:Review {body: "The Council of Elrond is a little long.", start: "2020-05-02", stop: "2020-05-05"})-[:REVIEWER]->(reviewer)
return b;



// The Two Towers

match
  (reviewer:User {email: "jean@jeantessier.com"})
create
  (b:Book {name: "The_Two_Towers", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1955]}),
  (b)-[:TITLE]->(:Title {title: "The Two Towers", link: "https://en.wikipedia.org/wiki/The_Two_Towers"}),
  (b)<-[:BOOK]-(:Review {body: "The Battle of Helm's Deep is a little long.", start: "2020-05-06", stop: "2020-05-10"})-[:REVIEWER]->(reviewer)
return b;



// The Return of the King

match
  (reviewer:User {email: "jean@jeantessier.com"})
create
  (b:Book {name: "The_Return_of_the_King", authors: ["J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1955]}),
  (b)-[:TITLE]->(:Title {title: "The Return of the King", link: "https://en.wikipedia.org/wiki/The_Return_of_the_King"}),
  (b)<-[:BOOK]-(:Review {body: "The ending is a little long.", start: "2020-05-11", stop: "2020-05-20"})-[:REVIEWER]->(reviewer)
return b;



// The Silmarillion

match
  (reviewer1:User {email: "jean@jeantessier.com"}),
  (reviewer2:User {email: "simon@tolkien.com"})
create
  (b:Book {name: "The_Silmarillion", authors: ["Christopher Tolkien", "J.R.R. Tolkien"], publisher: "Unwin & Allen", years: [1977]}),
  (b)-[:TITLE]->(:Title {title: "The Silmarillion", link: "https://en.wikipedia.org/wiki/The_Silmarillion"}),
  (b)<-[:BOOK]-(:Review {body: "Epic!", start: "2020-05-21", stop: "2020-05-30"})-[:REVIEWER]->(reviewer1),
  (b)<-[:BOOK]-(:Review {body: "Bacon!", start: "2019-12-11", stop: "2019-12-20"})-[:REVIEWER]->(reviewer2)
return b;



/*
 * End of File
 */
