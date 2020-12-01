package com.jeantessier

import grails.gorm.annotation.Entity
import grails.neo4j.Relationship

@Entity
class Review implements Relationship<User, Book> {

    String body
    String start
    String stop

    Date dateCreated
    Date lastUpdated

    static constraints = {
        start nullable: true
        stop nullable: true
    }

}
