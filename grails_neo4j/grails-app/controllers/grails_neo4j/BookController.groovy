package grails_neo4j

class BookController {

    static responseFormats = [ 'json', 'xml' ]

    def bookService

    def index() {
        respond Book.list()
    }

    def show(int id) {
        respond Book.get(id)
    }

    def find(String q) {
        respond bookService.findAll(q)
    }

}
