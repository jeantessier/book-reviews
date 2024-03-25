// Faker docs: https://fakerjs.dev/api/
const { faker } = require('@faker-js/faker')

module.exports.createUserWithRole = () => {
    const firstName = faker.person.firstName()
    const lastName = faker.person.lastName()

    return {
        name: faker.person.fullName({ firstName, lastName }),
        email: faker.internet.email({ firstName, lastName }),
        roles: ["ROLE_TEST_USER"],
    }
}

module.exports.createUserWithPassword = () => {
    const firstName = faker.person.firstName()
    const lastName = faker.person.lastName()
    const password = faker.internet.password()

    return {
        name: faker.person.fullName({ firstName, lastName }),
        email: faker.internet.email({ firstName, lastName }),
        password,
    }
}
