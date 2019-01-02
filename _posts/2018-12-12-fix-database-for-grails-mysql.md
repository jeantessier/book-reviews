---
layout: post
title: "Fix schema for Grails+MySQL"
date: 2018-12-13 02:38:00 -0800
categories: grails mysql
---
Moved the script to generate the schema and data for Grails with MySQL to that
application.  Added `role` and `user_role` tables.  Added `dateCreated` and
`lastUpdated` fields to entities.  Made a number of small adjustments.
