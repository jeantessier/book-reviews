describe('Book', () => {

    describe('create', () => {
        const registerUrl = Cypress.config('registerUrl')
        const loginUrl = Cypress.config('loginUrl')
        const bookUrl = Cypress.config('bookUrl')

        context('anonymous', () => {
            beforeEach(() => {
                cy.fixture('books/the_fellowship_of_the_ring').then(bookData => {
                    cy.request({
                        method: 'POST',
                        url: bookUrl,
                        body: bookData,
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
                cy.fixture('books/the_fellowship_of_the_ring').then(bookData => {
                    cy.request({
                        auth: { bearer: bearerToken },
                        method: 'POST',
                        url: bookUrl,
                        body: bookData,
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
                    cy.fixture('books/the_fellowship_of_the_ring').then(bookData => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: bookUrl,
                            body: bookData,
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
                    cy.fixture('books/the_fellowship_of_the_ring')
                        .then(expectedBook => {
                            cy.get('@request').should(response => {
                                const actualBook = response.body
                                expect(actualBook).to.have.property('name', expectedBook.name)
                                // expect(actualBook).to.have.deep.property('titles', expectedBook.titles)
                                expect(actualBook).to.have.property('publisher', expectedBook.publisher)
                                expect(actualBook).to.have.deep.property('authors', expectedBook.authors)
                                expect(actualBook).to.have.deep.property('years', expectedBook.years)
                                expect(actualBook).to.have.property('_id')
                            })
                        })
                })
            })

            context('missing name', () => {
                beforeEach(() => {
                    cy.fixture('books/the_fellowship_of_the_ring').then(({name, ... bookData}) => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: bookUrl,
                            body: bookData,
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

            context('book already exists', () => {
                beforeEach(() => {
                    cy.fixture('books/the_fellowship_of_the_ring').then(bookData => {
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: bookUrl,
                            body: bookData,
                            failOnStatusCode: false,
                        })
                        cy.request({
                            auth: { bearer: bearerToken },
                            method: 'POST',
                            url: bookUrl,
                            body: bookData,
                            failOnStatusCode: false,
                        }).as('request')
                    })
                })

                it('returns 409 Conflict', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 409)
                })
            })
        })
    })

})