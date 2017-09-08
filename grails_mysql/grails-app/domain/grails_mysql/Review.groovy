package grails_mysql

class Review {

    String body
    Date start
    Date stop

    static belongsTo = [
        reviewer: User,
        book: Book,
    ]

    static constraints = {
        start nullable: true
        stop nullable: true
    }

}
