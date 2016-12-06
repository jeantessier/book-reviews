---
layout: post
title:  "Exploring the MongoDB Schema in Grails"
date:   2016-12-05 22:19:00 -0800
categories: grails mongodb
---
I'm exploring how MongoDB and Grails represent object relationships.  The Grails
scaffolding doesn't let me set `hasMany` attributes like `years` and `authors`.
I had to set those using code.  These two are simply strings, but `titles` is an
embedded `Title` object and those are proving to be more difficult.  If I use:

    book.addToTitle(new Title(...).save())

I get an embedded object in the `book` collection entry and a separate
stand-alone entry in the `title` collection.  I was hoping for one or the other,
but not both.  If I don't save the `Title` instance, then I only get the
embedded entry in the `book` collection, but it has a null `_id` and it might be
difficult to edit them going forward.  I can save the title separately and only
put its ID in the list, but then Grails will not load it automatically; I have
to do it myself:

    book.titles.collect { Title.get(it) }

or

    Title.getAll(book.titles)

Neither of which is really appealing.

I always intended for `Title` to be embedded, but `Review` should definitely be
in a separate collection.  I can join the collections in MongoDB with this code:

    db.book.aggregate([
        {$unwind: "$reviews"},
        {$lookup: {
            from: "review",
            localField: "reviews",
            foreignField: "_id",
            as: "review"
        }},
        {$unwind: "$review"},
        {$project: {
            _id: false,
            name: true,
            authors: true,
            titles: true,
            publisher: true,
            years: true,
            start: "$review.start",
            stop: "$review.stop",
            body: "$review.body"
        }},
        {$sort: {start: -1}}
    ]);

But I have yet to figure out how to get Grails to run this query.
