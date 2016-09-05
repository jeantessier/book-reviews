package grails_mongo

class Book {

    String name
    List titles
    List<String> authors
    String publisher
    List<String> years

    static embedded = [ "titles" ]

    static constraints = {
        name unique: true
    }

}
