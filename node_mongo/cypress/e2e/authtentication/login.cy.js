describe('Authentication', () => {

    describe('login', () => {
        const url = Cypress.config('loginUrl')

        beforeEach(() => {
            cy.fixture('users/abc')
                .then(user => cy.createUser(user.name, user.email, user.password))
        })

        context('successful login', () => {

            beforeEach(() => {
                cy.fixture('users/abc')
                    .then(user => cy.request('POST', url, { email: user.email, password: user.password }).as('request'))
            })

            it('returns 200', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 200)
            })

            it('returns a JWT', () => {
                cy.get('@request')
                    .its('body')
                    .its('token')
                    .should('match', /\w+\.\w+\.\w+/)
            })
        })

        context('wrong email address', () => {

            beforeEach(() => {
                cy.fixture('users/abc')
                    .then(user => {
                        const body = { email: 'wrong email', password: user.password }
                        return cy.request({
                            method: 'POST',
                            url,
                            body,
                            failOnStatusCode: false,
                        }).as('request')
                    })
            })

            it('returns 401', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 401)
            })

            it('returns an error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('equal', 'Incorrect username.')
            })
        })

        context('wrong password', () => {

            beforeEach(() => {
                cy.fixture('users/abc')
                    .then(user => {
                        const body = { email: user.email, password: 'wrong password' }
                        return cy.request({
                            method: 'POST',
                            url,
                            body,
                            failOnStatusCode: false,
                        }).as('request')
                    })
            })

            it('returns 401', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 401)
            })

            it('returns an error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('equal', 'Incorrect password.')
            })
        })

    })

})