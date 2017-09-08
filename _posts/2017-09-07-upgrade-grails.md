---
layout: post
title:  "Upgrade Grails version on both Grails-based applications to 3.3.0"
date:   2017-09-07 23:45:00 -0700
categories: grails
---
Upgraded both Grails-based applications from `3.2.11` to `3.3.0`.  I generated
blank Grails `3.2.11` and `3.3.0` apps and compared key files as necessary.

* `build.gradle`
* `gradle.properties`
* `gradle/wrapper/gradle-wrapper.properties`
* `grails-app/assets/stylesheets/grails.css`
* `grails-app/conf/application.yml`
* `settings.gradle`

I discovered an issue with the `grails_mysql` app.  The `/book/index` and
`/book/show` actions throw weird exceptions.  I tried to adjust the definitions
for the many-to-many relationships, but it didn't fix it.  But if I empty the
database, everything works just fine.  There must be a piece of bad data
somewhere among the 108 test books that I'll need to track down.

And when I was testing the `grails_mongo` app, it didn't connect to the database
that I was expecting it to.  According to the connection string, it should
connect to my local MongoDB instance, which has some sample data.  But the UI
shows empty collections.  When I try to create entities, it records them
somewhere, but I can't figure out where for the life of me.
