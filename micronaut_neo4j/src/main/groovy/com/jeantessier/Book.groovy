package com.jeantessier

import grails.gorm.annotation.Entity

@Entity
class Book {

    String name
    String publisher

    static hasMany = [
            titles: Title,
            authors: String,
            years: String,
    ]

    Date dateCreated
    Date lastUpdated

    static constraints = {
        name blank: false, unique: true
    }

    static mapping = {
        titles type: "TITLE", fetch: "eager"
    }

}
