package grails_neo4j

class UserService {

    def findAll(q) {
        User.findAll("MATCH (n:User) where n.name =~ {1} or n.email =~ {1} RETURN n", q)
    }

}
