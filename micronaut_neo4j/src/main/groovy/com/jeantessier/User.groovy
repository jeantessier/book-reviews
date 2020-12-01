package com.jeantessier

import grails.gorm.annotation.*

@Entity
class User {

    String email
    String password
    String name

    Date dateCreated
    Date lastUpdated

    static constraints = {
        email email: true
        password nullable: true
        name blank: false
    }

}
