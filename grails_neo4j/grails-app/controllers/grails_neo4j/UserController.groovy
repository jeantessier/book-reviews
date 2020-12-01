package grails_neo4j

class UserController {

    static responseFormats = [ 'json', 'xml' ]

    UserService userService

    def index() {
        respond User.list()
    }

    def show(int id) {
        respond User.get(id)
    }

    def find(String q) {
        respond userService.findAll(q)
    }

}
