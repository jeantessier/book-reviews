---
layout: post
title:  "Generating the MongoDB Schema from Data Files"
date:   2016-12-07 22:56:00 -0800
categories: mongodb perl
---
Instead of a hard-coded JavaScript file to populate MongoDB, I use a Perl script
to generate it from the same data files I use to run my blog.  Now, I can update
the data files and quickly push the changes to MongoDB.

At first, I tried to pipe the output of the script directly to MongoDB:

    $ ./Books_mongo.pl | mongo book_reviews

But MongoDB kept complaining of _unterminated string literal_.  So instead, I
had to use a temporary file.

    $ ./Books_mongo.pl > book_reviews.js
    $ mongo book_reviews book_reviews.js

And it worked just fine.
