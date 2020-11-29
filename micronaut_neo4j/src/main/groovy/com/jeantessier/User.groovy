package com.jeantessier

import grails.gorm.annotation.*

@Entity
class User {

//    String id

    String email
    String password
    String name

    Date dateCreated
    Date lastUpdated

    static constraints = {
//        id maxSize: 36, nullable: true // Gets assigned automatically by the mapping generator
        email email: true
        password nullable: true
        name blank: false
    }

//    static mapping = {
//        id generator: "uuid2"
//    }

}
