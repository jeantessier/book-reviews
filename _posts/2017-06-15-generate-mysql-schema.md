---
layout: post
title:  "Generating the MySQL Schema from Data Files"
date:   2017-06-15 23:11:00 -0800
categories: mongodb perl
---
Instead of a hard-coded JavaScript file to populate MySQL, I use a Perl script
to generate it from the same data files I use to run my blog.  Now, I can update
the data files and quickly push the changes to MYSQL.

At first, I adapted the procedure from MongoDB:

    $ ./Books_grails_mysql.pl > book_reviews.sql
    $ mysql -u root book_reviews.sql

But then, I realized that I could pipe the output of the script directly to
MySQL:

    $ ./Books_grails_mysql.pl | mysql -u root

And it worked just fine.
