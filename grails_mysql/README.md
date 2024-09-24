# Grails with MySQL

This is a Grails application backed by a MySQL database.

These instructions assume you have installed [HTTPie](https://httpie.org/)
and MySQL's [command-line client](https://dev.mysql.com/doc/refman/9.0/en/mysql.html).
You can install `mysql-client` to get the client without installing the entire
database.

## MySQL

Run MySQL in a Docker container.

```bash
docker compose up -d
```

This command will create a new database named `grails_mysql_book_reviews` and
populate it with data derived from `../data/Books_????-??-??.md`.

```bash
./Books_grails_mysql.pl | mysql -u root
```

You can reset the database with these commands:

```bash
docker compose down
docker volume rm grails_mysql_mysql_data
docker compose up -d
```

## Running the Server

You can start the application with:

```bash
./gradlew bootRun
```

And point your browser to http://localhost:8080.

## Making REST Calls

To get a list of users:

```bash
http :8080/user/index.json
```

To get a list of books:

```bash
http :8080/book/index.json
```

To get the book with ID 2:

```bash
http :8080/book/show/2.json
```
