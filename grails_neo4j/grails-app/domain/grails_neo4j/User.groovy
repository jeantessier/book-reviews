package grails_neo4j

import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
class User {

    String email
    String password
    String name

    Date dateCreated
    Date lastUpdated

    static hasMany = [
            reviews: Review,
    ]

    static constraints = {
        email email: true
        password nullable: true
        name blank: false
    }

}
