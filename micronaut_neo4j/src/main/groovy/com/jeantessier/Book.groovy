package com.jeantessier

import grails.gorm.annotation.Entity

@Entity
class Book {

    String id

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
        id maxSize: 36 // Gets assigned when we create them
        name blank: false, unique: true
    }

    static mapping = {
        id generator: "assigned", name: "id"
        titles type: "TITLE", fetch: "eager"
    }

}
