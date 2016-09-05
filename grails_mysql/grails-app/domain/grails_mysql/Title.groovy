package grails_mysql

class Title {

    String title
    String link

    static contraints = {
        link nullable: true
    }

    static belongsTo = Book

}
