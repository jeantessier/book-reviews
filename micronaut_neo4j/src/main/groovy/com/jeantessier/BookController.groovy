package com.jeantessier

import grails.gorm.transactions.Transactional
import io.micronaut.http.annotation.*

import java.text.MessageFormat

@Controller("/books")
class BookController {

    @Get("/")
    @Transactional(readOnly = true)
    def index() {
        Book.list()
    }

    @Get("/{id}")
    @Transactional(readOnly = true)
    def show(id) {
        Book.get(id)
    }

    @Post("/")
    @Transactional
    def save(String name, String publisher, List<Title> titles, List<String> authors, List<String> years) {
        def book = new Book(id: UUID.randomUUID(), name: name, publisher: publisher, authors: authors, years: years)
        titles.each { book.addToTitles it }
        if (book.save()) {
            return book
        } else {
            return book.errors.allErrors.collect { MessageFormat.format(it.defaultMessage, it.arguments) }.join(", ")
        }
    }

    @Patch("/{id}")
    @Transactional
    def update(id, Optional<String> name, Optional<String> publisher, Optional<List<String>> authors, Optional<List<String>> years) {
        def book = Book.get(id)
        if (name.present) {
            book.name = name.get()
        }
        if (publisher.present) {
            book.publisher = publisher.get()
        }
        if (authors.present) {
            book.authors = authors.get()
        }
        if (years.present) {
            book.years = years.get()
        }
        if (book.save()) {
            return book
        } else {
            return book.errors.allErrors.collect { MessageFormat.format(it.defaultMessage, it.arguments) }.join(", ")
        }
    }

    @Delete("/")
    @Transactional
    def delete() {
        def numberDeleted = Book.executeUpdate("DELETE FROM book")
        return "Deleted ${numberDeleted} records."
    }

    @Delete("/{id}")
    @Transactional
    def delete(id) {
        def book = Book.get(id)
        if (book) {
            book.delete()
            return "OK"
        } else {
            return "Could not delete book ${id}."
        }
    }

}
