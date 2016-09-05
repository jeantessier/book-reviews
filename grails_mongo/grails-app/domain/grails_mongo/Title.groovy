package grails_mongo

class Title {

    String title
    String link

    static contraints = {
        link nullable: true
    }

    static belongsTo = Book

}
