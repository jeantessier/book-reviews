package com.jeantessier

import grails.gorm.annotation.*

@Entity
class User {

    String email
    String password
    String name

//    static hasMany = [
//            reviews: Review,
//    ]

    Date dateCreated
    Date lastUpdated

    static constraints = {
        email email: true
        password nullable: true
        name blank: false
    }

}
