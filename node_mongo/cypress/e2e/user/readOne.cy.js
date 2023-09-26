const path = require('path')

describe('User', () => {

    describe('readOne', () => {
        const registerUrl = Cypress.config('registerUrl')
        const loginUrl = Cypress.config('loginUrl')
        const userUrl = Cypress.config('userUrl')

        context('bad ID', () => {
            beforeEach(() => {
                cy.request({
                    method: 'GET',
                    url: path.join(userUrl, 'bad_id'),
                    failOnStatusCode: false,
                }).as('request')
            })

            it('returns 400 Bad Request', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 400)
            })

            it('returns error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('match', /Cast to ObjectId failed/)
            })
        })

        context('with user', () => {
            let userId

            beforeEach(() => {
                let bearerToken

                cy.fixture('users/admin').then(admin => {
                    cy.request('POST', registerUrl, admin)
                        .then(() => {
                            cy.grantRole(admin.email, "ROLE_ADMIN")
                        })
                    cy.request('POST', loginUrl, admin)
                        .then(response => {
                            bearerToken = response.body.token
                        })
                })

                cy.fixture('users/jean_tessier').then(userData => {
                    cy.request({
                        auth: { bearer: bearerToken },
                        method: 'POST',
                        url: userUrl,
                        body: userData,
                    }).then(response => {
                        userId = response.body._id
                    })
                })
            })

            context('found', () => {
                beforeEach(() => {
                    cy.request({
                        url: path.join(userUrl, userId),
                        failOnStatusCode: false,
                    }).as('request')
                })

                it('returns 200', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 200)
                })

                it('returns the populated user', () => {
                    cy.fixture('users/jean_tessier')
                        .then(expectedUser => {
                            cy.get('@request').should(response => {
                                const actualUser = response.body
                                expect(actualUser).to.have.property('name', expectedUser.name)
                                expect(actualUser).to.have.property('email', expectedUser.email)
                                expect(actualUser).to.have.deep.property('roles', expectedUser.roles)
                                expect(actualUser).to.not.have.property('password')
                                expect(actualUser).to.have.property('_id')
                                expect(actualUser).to.not.have.property('salt')
                                expect(actualUser).to.not.have.property('hash')
                            })
                        })
                })
            })

            context('not found', () => {
                beforeEach(() => {
                    cy.resetDb()
                    cy.request({
                        url: path.join(userUrl, userId),
                        failOnStatusCode: false,
                    }).as('request')
                })

                it('returns 404 Not Found', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 404)
                })

                it('returns error message', () => {
                    cy.get('@request')
                        .its('body')
                        .its('message')
                        .should('equal', 'No user with ID ' + userId)
                })
            })
        })
    })

})