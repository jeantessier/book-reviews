---
layout: post
title:  "Upgrade Grails version on both Grails-based applications to 3.2.4"
date:   2017-01-26 23:01:00 -0800
categories: grails
---
Upgraded both Grails-based applications from `3.1.x` to `3.2.4`.  I had to
upgrade the Gradle wrapper and update dependencies.  So, I generated a blank
Grails `3.2.4` app and compared key files as necessary.

* `build.gradle`
* `gradle.properties`
* `grails-app/conf/application.yml`
