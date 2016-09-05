package grails_mysql

class Review {

    Book book
    User reviewer
    String body
    Date start
    Date stop

    static constraints = {
        stop nullable: true
    }

}
