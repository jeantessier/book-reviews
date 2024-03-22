describe('User', () => {

    describe('create', () => {
        const registerUrl = Cypress.config('registerUrl')
        const loginUrl = Cypress.config('loginUrl')
        const userUrl = Cypress.config('userUrl')

        context('anonymous', () => {
            beforeEach(() => {
                cy.fixture('users/abc').then(userData => {
                    cy.request({
                        method: 'POST',
                        url: userUrl,
                        body: userData,
                        failOnStatusCode: false,
                    }).as('request')
                })
            })

            it('returns 401 Unauthenticated', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 401)
            })
        })

        context('unauthorized user', () => {
            beforeEach(() => {
                let bearerToken

                cy.fixture('users/jean_tessier').then(jean => {
                    cy.request('POST', registerUrl, jean)
                        .then(response => {
                            bearerToken = response.body.token
                        })
                })
                cy.fixture('users/abc').then(userData => {
                    cy.request({
                        auth: { bearer: bearerToken },
                        method: 'POST',
                        url: userUrl,
                        body: userData,
                        failOnStatusCode: false,
                    }).as('request')
                })
            })

            it('returns 403 Unauthorized', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 403)
            })
        })

        context('authorized user', () => {
            let bearerToken

            beforeEach(() => {
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
            })

            context('all required fields', () => {
                beforeEach(() => {
                    cy.fixture('users/abc').then(userData => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: userUrl,
                            body: userData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 201 Created', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 201)
                })

                it('returns the populated user', () => {
                    cy.fixture('users/abc')
                        .then(expectedUser => {
                            cy.get('@request').should(response => {
                                const actualUser = response.body
                                expect(actualUser).to.have.property('name', expectedUser.name)
                                expect(actualUser).to.have.property('email', expectedUser.email)
                                expect(actualUser).to.have.deep.property('roles', expectedUser.roles)
                                expect(actualUser).to.not.have.property('password')
                                expect(actualUser).to.have.property('_id')
                                expect(actualUser).to.have.property('salt')
                                expect(actualUser).to.have.property('hash')
                            })
                        })
                })
            })

            context('missing name', () => {
                beforeEach(() => {
                    cy.fixture('users/abc').then(({name, ... userData}) => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: userUrl,
                            body: userData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 400', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 400)
                })
            })

            context('missing email', () => {
                beforeEach(() => {
                    cy.fixture('users/abc').then(({email, ... userData}) => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: userUrl,
                            body: userData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 400', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 400)
                })
            })

            context('missing password', () => {
                beforeEach(() => {
                    cy.fixture('users/abc').then(({password, ... userData}) => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: userUrl,
                            body: userData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 400', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 400)
                })
            })

            context('user already exists', () => {
                beforeEach(() => {
                    cy.fixture('users/admin').then(userData => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: userUrl,
                            body: userData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 409', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 409)
                })
            })
        })
    })

})