package grails_neo4j

import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
class Book {

    String name
    String publisher

    Date dateCreated
    Date lastUpdated

    static hasMany = [
            titles: Title,
            authors: String,
            years: String,
            reviews: Review,
    ]

    static constraints = {
        name blank: false, unique: true
    }

    static mapping = {
        titles type: "TITLE", fetch: "eager"
    }

}
