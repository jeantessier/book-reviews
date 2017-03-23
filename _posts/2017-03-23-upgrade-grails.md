---
layout: post
title:  "Upgrade Grails version on both Grails-based applications to 3.2.8"
date:   2017-03-23 11:23:00 -0800
categories: grails
---
Of course, Grails 3.2.8 comes out the very next day after I upgraded to
Grails 3.2.7.

Upgraded both Grails-based applications from `3.2.7` to `3.2.8`.  I had to
upgrade the Gradle wrapper and update dependencies.  So, I generated blank
Grails `3.2.7` and `3.2.8` apps and compared key files as necessary.

* `build.gradle`
* `gradle.properties`
* `grails-app/conf/application.yml`
* `grails-app/conf/logback.groovy`
* `settings.gradle`
