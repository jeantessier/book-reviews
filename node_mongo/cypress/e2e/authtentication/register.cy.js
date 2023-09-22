describe('Authentication', () => {

    describe('register', () => {
        const url = Cypress.config('registerUrl')

        context('new user', () => {
            const body = {
                name: 'Abc',
                email: 'abc@bookreviews.com',
                password: 'abcd1234',
            }

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

        context('user already exists', () => {
            const body = {
                name: 'Abc',
                email: 'abc@bookreviews.com',
                password: 'abcd1234',
            }

            beforeEach(() => {
                cy.request('POST', url, body).as('firstRequest')
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('secondRequest')
            })

            it('returns 404', () => {
                cy.get('@firstRequest')
                    .its('status')
                    .should('equal', 200)
                cy.get('@secondRequest')
                    .its('status')
                    .should('equal', 404)
            })
        })

        context('missing name', () => {
            const body = {
                email: 'abc@bookreviews.com',
                password: 'abcd1234',
            }

            beforeEach(() => {
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('request')
            })

            it('returns 400', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 400)
            })

            it('returns an error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('equal', 'All fields required')
            })
        })

        context('missing email address', () => {
            const body = {
                name: 'Abc',
                password: 'abcd1234',
            }

            beforeEach(() => {
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('request')
            })

            it('returns 400', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 400)
            })

            it('returns an error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('equal', 'All fields required')
            })
        })

        context('missing password', () => {
            const body = {
                name: 'Abc',
                email: 'abc@bookreviews.com',
            }

            beforeEach(() => {
                cy.request({
                    method: 'POST',
                    url,
                    body,
                    failOnStatusCode: false,
                }).as('request')
            })

            it('returns 400', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 400)
            })

            it('returns an error message', () => {
                cy.get('@request')
                    .its('body')
                    .its('message')
                    .should('equal', 'All fields required')
            })
        })

    })

})