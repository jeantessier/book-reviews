package grails_mongo

import org.bson.types.ObjectId

class Review {

    ObjectId id

    Book book
    User reviewer
    String body
    Date start
    Date stop

    Date dateCreated
    Date lastUpdated

    static constraints = {
        start nullable: true
        stop nullable: true
    }

    static mapping = {
	    body type: "text"
    }

}
