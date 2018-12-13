package grails_mysql

import groovy.transform.EqualsAndHashCode
import groovy.transform.ToString
import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
@EqualsAndHashCode(includes='email')
@ToString(includes='name,email', includeNames=true, includePackage=false)
class User implements Serializable {

    private static final long serialVersionUID = 1

    String name
    String email
    String password
    boolean enabled = true
    boolean accountExpired = false
    boolean accountLocked = false
    boolean passwordExpired = false

    Date dateCreated
    Date lastUpdated

    Set<Role> getAuthorities() {
        (UserRole.findAllByUser(this) as List<UserRole>)*.role as Set<Role>
    }

    static constraints = {
        name blank: false
        email blank: false, unique: true
        password blank: false, password: true
    }

    static mapping = {
	    password column: '`password`'
    }

}
