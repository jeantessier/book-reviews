package grails_mongo

import org.bson.types.ObjectId

class Book {

    ObjectId id

    String name
    List titles
    List<String> authors
    String publisher
    List<String> years

    static embedded = [ "titles" ]

    static constraints = {
        name unique: true
    }

}
