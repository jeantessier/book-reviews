package grails_mongo

class Book {

    String name
    String publisher

    static hasMany = [
        titles: Title,
        authors: String,
        years: String,
    ]

    static constraints = {
        name unique: true
    }

}
