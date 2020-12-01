package grails_neo4j

import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
class Title {

    String title
    String link

    static belongsTo = Book

    static constraints = {
        title blank: false
        link nullable: true
    }

}
