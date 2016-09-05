---
layout: post
title:  "Data Model in Node with MongoDB"
date:   2016-09-04 21:52:00 -0700
categories: node mongodb mongoose
---
Completed the full data model in MongoDB using Node's Mongoose plugin.

I have temporarily updated the data dump to seed the database to account for
the fact that Mongoose uses plural names for collections.  You can apply the
data with:

    mongo node_mongo_book_reviews ../data/book_reviews.js

With the data in place, I can merge books and their reviews with a query like:

    db.books.aggregate([
        {$unwind: "$reviews"},
        {$lookup: {
            from: "reviews",
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

I will need to update this query to look up reviewers from the `users`
collection and account for one book having multiple reviews.  And I will also
want an similar query that works from the user's perspective.  I need to be able
to look up one book and its reviews, or one reviewers and their reviews.
