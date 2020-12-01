package grails_neo4j

import grails.neo4j.Relationship

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
