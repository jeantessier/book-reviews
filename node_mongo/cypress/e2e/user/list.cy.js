describe('User', () => {

    describe('list', () => {
        const userUrl = Cypress.config('userUrl')

        context('no users', () => {
            beforeEach(() => {
                cy.request(userUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .should('be.ok')
            })

            it('gets an empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('be.empty')
            })
        })

        context('with one user', () => {
            beforeEach(() => {
                cy.fixture('users/abc')
                    .then(user => cy.populateUser(user))
                cy.request(userUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .should('be.ok')
            })

            it('gets a non-empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('have.lengthOf', 1)
            })

            it('includes the populated user', () => {
                cy.fixture('users/abc')
                    .then(({ password, ... expectedUser }) => {
                        cy.get('@request').should(response => {
                            const actualUser = response.body[0]
                            expect(actualUser).to.have.property('name', expectedUser.name)
                            expect(actualUser).to.have.property('email', expectedUser.email)
                            expect(actualUser).to.have.deep.property('roles', expectedUser.roles)
                            expect(actualUser).to.not.have.property('password')
                            expect(actualUser).to.not.have.property('salt')
                            expect(actualUser).to.not.have.property('hash')
                        })
                    })
            })
        })

        context('with multiple users', () => {
            beforeEach(() => {
                cy.populateAllUsers()
                cy.request(userUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .should('be.ok')
            })

            it('gets a non-empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('have.lengthOf', 3)
            })
        })
    })

})