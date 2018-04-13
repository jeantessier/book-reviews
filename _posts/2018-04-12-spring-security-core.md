---
layout: post
title:  "Use Grails plugin spring-security-core for authentication"
date:   2018-04-12 20:00:00 -0800
categories: grails
---
I tried to replace my custom `User` class with Grails'
[spring-security-core](http://plugins.grails.org/plugin/grails/spring-security-core)
plugin.  It includes roles to deal with authorization aspects.

I followed the steps in the documentation for both
[spring-security-core](https://grails-plugins.github.io/grails-spring-security-core/3.1.x/index.html)
[spring-security-ui](https://grails-plugins.github.io/grails-spring-security-ui/latest/)
plugins.  I created the artifacts with:

    $ grails s2-quickstart grails_mysql User Role

But the Grails bootstrap gets a `NullPointerException` as it tries to setup
dependency injection.
