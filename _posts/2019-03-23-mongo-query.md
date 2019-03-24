---
layout: post
title:  "Playing with MongoDB Queries"
date:   2019-03-23 20:34:00 -0700
categories: mongodb
---
Still fine-tuning a MongoDB query to fetch reviews for a given book.  I removed
the `reviews` fields of `User` and `Book` because maintaining them was too much
duplicated work.  Instead, I reworked the query to pull what it needs from the
`db.reviews` collection.

In this example, I'm looking for books with the work "Lord" in their name.

    db.books.aggregate([
        {$match: {
            name: {$regex: /Lord/}
        }},
        {$lookup: {
            from: "reviews",
            localField: "_id",
            foreignField: "book",
            as: "review"
        }},
        {$unwind: "$review"},
        {$lookup: {
            from: "users",
            localField: "review.reviewer",
            foreignField: "_id",
            as: "reviewer"
        }},
        {$unwind: "$reviewer"},
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
            reviewer: "$reviewer.name",
            email: "$reviewer.email",
        }},
        {$sort: {start: -1}},
    ])

On my dev machine, using MongoDB 3.2.10, the first `$lookup` stage returns only
one match.  I created a MongoDB 3.6.9 instance on [mLab](https://mlab.com/) and
it successfully matched all relevant documents.  Weird.
