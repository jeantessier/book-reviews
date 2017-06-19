package grails_mysql

class User {

    String name
    String email
    String password
    String salt

    static hasMany = [ Review ]

    static constraints = {
        email unique: true
    }

}
