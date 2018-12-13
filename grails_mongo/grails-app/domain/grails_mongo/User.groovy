package grails_mongo

import org.bson.types.ObjectId

class User {

    ObjectId id

    String name
    String username
    String password

    Date dateCreated
    Date lastUpdated

    static hasMany = [ Review ]

    static constraints = {
        name blank: false
        username blank: false, unique: true
        password blank: false, password: true
    }

    static mapping = {
	    password column: '`password`'
    }

}
