---
layout: post
title:  "Upgrade Grails version on both Grails-based applications to 3.2.7"
date:   2017-03-22 22:10:00 -0800
categories: grails
---
Upgraded both Grails-based applications from `3.2.5` to `3.2.7`.  I had to
upgrade the Gradle wrapper and update dependencies.  So, I generated a blank
Grails `3.2.5` and `3.2.7` apps and compared key files as necessary.

* `build.gradle`
* `gradle.properties`
* `gradle/wrapper/gradle-wrapper.properties`
* `grails-wrapper.jar`
* `grailsw`
* `grailsw.bat`
