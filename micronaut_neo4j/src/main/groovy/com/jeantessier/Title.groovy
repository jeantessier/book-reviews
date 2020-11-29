package com.jeantessier

import grails.gorm.annotation.Entity

@Entity
class Title {

    String title
    String link

    static belongsTo = Book

    static constraints = {
        title blank: false
        link nullable: true
    }

}
