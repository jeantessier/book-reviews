---
layout: post
title:  "Upgrade GORM version on both Grails-based applications to 6.1.8"
date:   2017-11-02 15:01:00 -0700
categories: grails
---
Upgraded GORM on both Grails-based applications from `6.1.7` (standard for
Grails 3.3.1) to `6.1.8`.  A
[tweet](https://twitter.com/grailsframework/status/926019213306757121) from the
official Grails account hinted that it would be trivial.  And it was, as far as
I can tell.  I just changed the version number in `gradle.properties` and
everything kept on working just like before.
