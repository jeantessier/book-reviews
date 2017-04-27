---
layout: post
title:  "Playing with MongoDB Queries"
date:   2017-04-26 23:14:00 -0700
categories: mongodb
---
I'm playing with building queries in MongoDB that join the `Book`, `Review`, and
`User` collections, so that each entry has the text of the review and the name
and email of the reviewer.  I also experimented with putting a filter in the
query to zero-in on a specific book.

In this example, I'm looking for the book with name "Numero_Zero".

    db.book.aggregate([
        {$match: {
            "name": "Numero_Zero"
        }},
        {$unwind: "$reviews"},
        {$lookup: {
            from: "review",
            localField: "reviews",
            foreignField: "_id",
            as: "review"
        }},
        {$unwind: "$review"},
        {$lookup: {
            from: "user",
            localField: "review.writer",
            foreignField: "_id",
            as: "writer"
        }},
        {$unwind: "$writer"},
        {$project: {
            _id: false,
            name: true,
            authors: true,
            titles: true,
            publisher: true,
            years: true,
            start: "$review.start",
            stop: "$review.stop",
            body: "$review.body",
            writer: "$writer.name",
            email: "$writer.email"
        }},
        {$sort: {start: -1}}
    ]);
