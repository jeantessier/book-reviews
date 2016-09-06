package grails_mongo

import org.bson.types.ObjectId

class Review {

    ObjectId id

    Book book
    User reviewer
    String body
    Date start
    Date stop

    static constraints = {
        stop nullable: true
    }

}
