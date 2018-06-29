---
layout: post
title:  "Upgrade Node packages, including replacing Jade with Pug"
date:   2018-06-28 23:23:00 -0800
categories: node jade pug
---
I ran `npm install` to upgrade components.  It listed some vulnerabilities that
I fixed with:

    $ npm audit fix --force

I still had to replace `jade` with `pug`, since the old `jade` package is now
deprecated.  I got the templates to work, but I got an error when I tried to
login.  I'll have to investigate `mongoose` changes next.
