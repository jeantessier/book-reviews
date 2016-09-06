---
layout: post
title:  "Early Experiements with Grails"
date:   2016-09-05 15:29:00 -0700
categories: grails mongodb mysql
---
Created a Grails 3 app backed by MongoDB.  I couldn't get the GORM integration
to work right at first.  It took me bit of research before finally figuring out
what I was doing wrong.  Turned out to have to do with interference between
Hibernate and the `mongodb` plugin.

I also created another Grails 3 app, but backed by MySQL this time.  This one
went a lot smoother.

I can't get the Grails shell working under Grails 3.1.11.  It makes
experimenting with the data objects that much more difficult.
