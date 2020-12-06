package com.jeantessier

import grails.gorm.annotation.Entity

@Entity
class Book {

    String name
    String publisher

    Date dateCreated
    Date lastUpdated

    static hasMany = [
            titles: Title,
            authors: String,
            years: String,
    ]

    static constraints = {
        name blank: false, unique: true
    }

    static mapping = {
        titles type: "TITLE", fetch: "eager"
    }

    def getReviews() {
        Review.where { book == this }.list()
    }

}
