---
layout: post
title: "Build the App As Cooperating Microservices"
date: 2019-01-01 23:50:00 -0700
categories: microservices
---
What if each part of the app was its own microservice?  The `books` microservice
holds the data for each book, but nothing else.  The `reviews` microservice
holds the data for each review, including ids for the book and the reviewer.
The `users` microservice holds the data for each user, including passwords and
roles.  It can put the roles in the JWT that the user gets when they login.

They could coordinate with one another using a message broker, such as RabbitMQ.
Each microservice publishes events when an entity is created, modified, or
deleted.  Services listen to the events that is of interest to them.

For instance, the `reviews` microservice listens for `USER_DELETED` and
`BOOK_DELETED` events to delete corresponding reviews (and trigger
`REVIEW_DELETED` events).

A `search` microservice could maintain its own index of searchable content by
listening to all the events and updating the index appropriately.

I started drafting a simple architecture diagram:

![microservice architecture overview]({{ site.baseurl }}/assets/images/2019-01-01-microservices-overview.png)

And some sequence diagram that show the control flow for simple use cases:

* User creates a review.
    ![User write a review]({{ site.baseurl }}/assets/images/2019-01-01-sequence-diagram-create-review.png)
* User edits a review.
    ![User updates a review]({{ site.baseurl }}/assets/images/2019-01-01-sequence-diagram-update-review.png)
* User deletes a review.
    ![User deletes a review]({{ site.baseurl }}/assets/images/2019-01-01-sequence-diagram-delete-review.png)
* User requests to be forgotten.
    ![User requests to be forgotten]({{ site.baseurl }}/assets/images/2019-01-01-sequence-diagram-delete-user.png)

I did the architecture overview in Google Docs.  It works, but I am still
getting used to it.  I'm using [PlantUML](https://plantuml.com/) for the
sequence diagrams.
