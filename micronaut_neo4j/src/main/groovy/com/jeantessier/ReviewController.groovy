package com.jeantessier

import grails.gorm.transactions.Transactional
import io.micronaut.http.HttpResponse
import io.micronaut.http.annotation.*

import java.text.MessageFormat

@Controller("/reviews")
class ReviewController {

    @Get("/user/{userId}/book/{bookId}")
    @Transactional
    def show(userId, bookId) {
        def user = User.get(userId)
        def book = Book.get(bookId)
        Review.where {
            reviewer == user && book == book
        }.list()
    }

    @Post("/user/{userId}/book/{bookId}")
    @Transactional
    def save(userId, bookId, String body, Optional<String> start, Optional<String> stop) {
        def user = User.get(userId)
        def book = Book.get(bookId)
        def review = new Review(reviewer: user, book: book, body: body, start: start.get(), stop: stop.get())
        if (review.save()) {
            return HttpResponse.created(review)
        } else {
            return HttpResponse.badRequest(review.errors.allErrors.collect { MessageFormat.format(it.defaultMessage, it.arguments) }.join(", "))
        }
    }

}
