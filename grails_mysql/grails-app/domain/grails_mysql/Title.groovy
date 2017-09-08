package grails_mysql

class Title {

    String title
    String link

    static belongsTo = [ book: Book ]

    static contraints = {
        link nullable: true
    }

}
