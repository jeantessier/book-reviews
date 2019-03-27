---
layout: post
title: "Upgrade Grails version on both Grails-based applications to 4.0.0.M2"
date: 2019-03-27 00:53:00 -0700
categories: grails
---
Upgraded both Grails-based applications from `3.3.9` to `4.0.0.M2`.  I generated
blank Grails `3.3.9` and `4.0.0.M2` apps and compared key files as necessary.

* build.gradle
* gradle/wrapper/gradle-wrapper.jar
* gradle/wrapper/gradle-wrapper.properties
* gradle.properties
* gradlew
* gradlew.bat
* grails-app/assets/images/apple-touch-icon-retina.png
* grails-app/assets/images/apple-touch-icon.png
* grails-app/assets/images/favicon.ico
* grails-app/conf/application.yml
* grails-app/conf/logback.groovy
* grails-app/init/blank/Application.groovy
* grails-wrapper.jar

I'm getting an error related to `spring-security-core`, which possibly hasn't
been upgraded to 4.0.0 just yet.

    General error during instruction selection: java.lang.NoClassDefFoundError: org.springframework.security.core.Authentication
