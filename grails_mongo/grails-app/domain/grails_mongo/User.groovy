package grails_mongo

import org.bson.types.ObjectId

class User {

    ObjectId id

    String name
    String email
    String hash
    String salt

    static hasMany = [ Review ]

    static constraints = {
        email unique: true
    }

}
