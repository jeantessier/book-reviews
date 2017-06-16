# Data

The `data/` folder has scripts to seed the data storage with initial entities.

## MySQL

This command will create a new database named `grails_mysql_book_reviews` and populate it with collections derived from `Books_????-??-??.txt`.

    $ Books_grails_mysql.pl | mysql -u root

## MongoDB

This command will create a new database named `book_reviews` and populate it with collections derived from `Books_????-??-??.txt`.

    $ ./Books_mongo.pl > book_reviews.js
    $ mongo book_reviews book_reviews.js
