---
layout: post
title: "Break Up Book Into More Entities"
date: 2022-01-21 10:55:00 -0800
categories: modeling
---
I was looking at the data in one of the MySQL variants and noticed quite a bit
of data duplication in authors and publishers.  I wondered if it would be
worthwhile to remove that duplication by promoting authors, years, and maybe
even publishers, to full-fledged entities.

This is the original schema, where authors are simply listed on the `Book`
entity.

![straightforward setup]({{ site.baseurl }}/assets/images/2022-01-21-original-model-class-diagram.png)

And here is a version with separate entities for authors, years, and publishers.

![straightforward setup]({{ site.baseurl }}/assets/images/2022-01-21-separate-entities-model-class-diagram.png)

The separate entities allow us to navigate to the books by the same author, or
at the same publisher, or from the same year.  We can already achieve something
similar with search terms, but would the extra complexity be worth the small
improvement in features?

Probably not.

The goal of this project is to have something substantial to explore different
relationships in various tech stacks without it becoming overwhelming.
Representing lists of primitives can be an interesting challenge on its own.
The relationship of `Book` to `Title` models a classic association between
entities.  The relationships of `Book` to `authors` and `years` is that of an
entity to atomic types.  They provide an opportunity, within the frame of the
exercise, to explore how to implement different kinds of data relationships.

I'm using [PlantUML](https://plantuml.com/) for the class diagrams.
