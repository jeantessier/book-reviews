---
layout: post
title:  "Problems with scaffolding in Grails 3.3.0"
date:   2017-09-13 21:41:00 -0700
categories: grails
---
After I upgraded to Grails 3.3.0, I noticed that my scaffolding `BookController`
was throwing exceptions.  I narrowed it down to the presence of non-empty
one-to-many relationships for `Book.authors`, `Book.titles`, or `Book.years`.
All of these are embedded objects of type `String` or `Title`.  When the fields
are empty, everything is fine.  But the moment any one of them has even a single
value, the scaffolding code chokes on them.  There is no problem with the
relationship between `Book` and `Review` because the scaffolding is ignoring it
altogether.

Switching from web scaffolding to REST with JSON output does exhibit that
problem.  Other than still not showing reviews, that is.
