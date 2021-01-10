package com.jeantessier

import com.fasterxml.jackson.annotation.JsonIgnore
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

    @JsonIgnore
    def getReviews() {
        Review.where { reviewer == this }.list()
    }

}
