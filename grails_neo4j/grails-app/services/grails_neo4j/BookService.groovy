package grails_neo4j

class BookService {

    def findAll(q) {
        Book.findAll("MATCH (n:Book) where n.name =~ {1} RETURN n", q)
    }

}
