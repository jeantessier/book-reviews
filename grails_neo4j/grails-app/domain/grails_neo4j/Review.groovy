package grails_neo4j

class Review {

    String body
    String start
    String stop

    Date dateCreated
    Date lastUpdated

    static belongsTo = [
            reviewer: User,
            book: Book,
    ]

    static constraints = {
        start nullable: true
        stop nullable: true
    }

}
