---
layout: post
title: "Upgrade Grails version on both Grails-based applications to 4.0.0.RC1"
date: 2019-05-01 22:54:00 -0700
categories: grails
---
Upgraded both Grails-based applications from `3.3.9` or `4.0.0.M2` to
`4.0.0.RC1`.  I generated blank Grails `3.3.9`, `4.0.0.M2`, and `4.0.0.RC1` apps
and compared key files as necessary.

For upgrading `grails_mysql` from `3.3.9` to `4.0.0.RC1`, the files were:

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
* src/integration-test/resources/GebConfig.groovy

For upgrading `grails_mongo` from `4.0.0.M2` to `4.0.0.RC1`, the files were:

* build.gradle
* gradle.properties
* grails-app/conf/application.yml
* src/integration-test/resources/GebConfig.groovy
