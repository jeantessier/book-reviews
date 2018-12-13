package grails_mongo

import org.bson.types.ObjectId

class Book {

    ObjectId id

    String name
    List titles
    List<String> authors
    String publisher
    List<String> years

    Date dateCreated
    Date lastUpdated

    static embedded = [ "titles" ]

    static hasMany = [ Review ]

    static constraints = {
        name unique: true
    }

}
