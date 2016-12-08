# Data

The `data/` folder has scripts to seed the data storage with initial entities.

## MySQL

This command will create a new database named `book_reviews` and populate it with tables defined in `data/book_reviews.sql`.

    $ mysql -u root < book_reviews.sql

## MongoDB

This command will create a new database named `book_reviews` and populate it with collections defined in `data/book_reviews.js`.

    $ mongo book_reviews book_reviews.js
