package grails_neo4j

class ReviewService {

    def findAll(q) {
        Review.where { body =~ q }.list()
    }

}
