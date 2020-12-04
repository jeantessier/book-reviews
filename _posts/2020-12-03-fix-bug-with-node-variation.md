---
layout: post
title: "Fix Bug With Node Variation"
date: 2020-12-03 22:01:00 -0800
categories: node mongodb
---
The Node w/ MongoDB variation is the only one that deals the user roles outlined
in the requirements.  More specifically, require #6 says that a user can delete
their own reviews, and it kinda infers that they cannot delete another user's
reviews.

There was a bug with the way this was implemented in the Express controller for
reviews.  It was calling `Review.findOneAndDelete()` first, and _then_ checking
if the user was allowed to delete that record.  The user would still get an
error message if they tried to delete someone else's review, but the damage had
already been done anyway.  It was kinda nice that it took only a single call  to
the database, but it had to be fixed.

I had to first fetch the record with `Review.findOne()`, check that the user was
permitted to delete it, then delete it with `Review.deleteOne()`.

I guess I could have used `Review.findAndDeleteOne()` and add a check on the
reviewer in the filter when the logged in user wasn't an admin.  But, I would
have lost the ability to distinguish between trying to delete a record that does
not exist (`404 Not Found`) and trying to delete someone else's record
(`403 Forbidden`).

I also added logic to delete multiple records.  An admin can delete all books,
or all reviews, or all users.  It is funny that the roles and permissions are
taken from the JWT, so the admin can continue to wreak havoc even after their
user account has been deleted, as long as their JWT has not expired.  Regular
users can only delete all of **their own** reviews.
