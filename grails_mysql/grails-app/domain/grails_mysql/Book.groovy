package grails_mysql

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
        name unique: true
    }

}
