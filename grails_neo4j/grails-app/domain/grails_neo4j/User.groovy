package grails_neo4j

import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
class User {

    String email
    String password
    String name

//    static hasMany = [
//            reviews: Review,
//    ]

    Date dateCreated
    Date lastUpdated

    static constraints = {
        email email: true
        password nullable: true
        name blank: false
    }

}
