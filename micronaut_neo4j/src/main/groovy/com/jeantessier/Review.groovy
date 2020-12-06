package com.jeantessier

import grails.gorm.annotation.Entity

@Entity
class Review {

    String body
    String start
    String stop

    Date dateCreated
    Date lastUpdated

    static hasOne = [
            reviewer: User,
            book: Book,
    ]

    static constraints = {
        start nullable: true
        stop nullable: true
    }

}
