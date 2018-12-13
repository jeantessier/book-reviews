package grails_mongo

import org.bson.types.ObjectId

class Title {

    ObjectId id

    String title
    String link

    static belongsTo = [ book: Book ]

    static constraints = {
        link nullable: true
    }

}
