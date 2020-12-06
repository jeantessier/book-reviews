package com.jeantessier

import grails.gorm.transactions.Transactional
import io.micronaut.http.HttpResponse
import io.micronaut.http.annotation.*
import java.text.*

@Controller("/users")
class UserController {

    @Get("/")
    @Transactional(readOnly = true)
    def index() {
        User.list()
    }

    @Get("/{id}")
    @Transactional(readOnly = true)
    def show(id) {
        User.get(id)
    }

    @Post("/")
    @Transactional
    def save(String email, String password, String name) {
        def user = new User(email: email, password: password, name: name)
        if (user.save()) {
            return HttpResponse.created(user)
        } else {
            return HttpResponse.badRequest(user.errors.allErrors.collect { MessageFormat.format(it.defaultMessage, it.arguments) }.join(", "))
        }
    }

    @Patch("/{id}")
    @Transactional
    def update(id, Optional<String> email, Optional<String> password, Optional<String> name) {
        def user = User.get(id)
        if (email.present) {
            user.email = email.get()
        }
        if (password.present) {
            user.password = password.get()
        }
        if (name.present) {
            user.name = name.get()
        }
        if (user.save()) {
            return user
        } else {
            return HttpResponse.badRequest(user.errors.allErrors.collect { MessageFormat.format(it.defaultMessage, it.arguments) }.join(", "))
        }
    }

    @Delete("/")
    @Transactional
    def delete() {
        def numberDeleted = User.executeUpdate("DELETE FROM user")
        return "Deleted ${numberDeleted} records."
    }

    @Delete("/{id}")
    @Transactional
    def delete(id) {
        def user = User.get(id)
        if (user) {
            user.delete()
            return HttpResponse.noContent()
        } else {
            return HttpResponse.notFound("Could not delete user ${id}.")
        }
    }

}
