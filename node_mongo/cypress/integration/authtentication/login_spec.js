describe('Authentication', () => {

    describe('login', () => {
        const url = Cypress.config('loginUrl')

        const email = 'abc@bookreviews.com'
        const password = 'abcd1234'

        beforeEach(() => {
            cy.createUser('Abc', email, password)
        })

        context('successful login', () => {
            const body = { email, password }

            beforeEach(() => {
                cy.request('POST', url, body).as('request')
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
            const body = { email: 'wrong email', password }

            beforeEach(() => {
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('request')
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
            const body = { email, password: 'wrong password' }

            beforeEach(() => {
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('request')
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