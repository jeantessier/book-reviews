package grails_neo4j

class ReviewController {

    static responseFormats = [ 'json', 'xml' ]

    def reviewService

    def find(String q) {
        respond reviewService.findAll(q)
    }

}
