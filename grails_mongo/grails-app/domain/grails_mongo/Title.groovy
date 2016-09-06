package grails_mongo

import org.bson.types.ObjectId

class Title {

    ObjectId id

    String title
    String link

    static contraints = {
        link nullable: true
    }

    static belongsTo = Book

}
