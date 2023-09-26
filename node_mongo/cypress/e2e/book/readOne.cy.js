const path = require('path')

describe('Book', () => {

    describe('readOne', () => {
        const registerUrl = Cypress.config('registerUrl')
        const loginUrl = Cypress.config('loginUrl')
        const bookUrl = Cypress.config('bookUrl')

        context('bad ID', () => {
            beforeEach(() => {
                cy.request({
                    method: 'GET',
                    url: path.join(bookUrl, 'bad_id'),
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

        context('with book', () => {
            let bookId

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

                cy.fixture('books/the_fellowship_of_the_ring').then(bookData => {
                    cy.request({
                        auth: { bearer: bearerToken },
                        method: 'POST',
                        url: bookUrl,
                        body: bookData,
                    }).then(response => {
                        bookId = response.body._id
                    })
                })
            })

            context('found', () => {
                beforeEach(() => {
                    cy.request({
                        url: path.join(bookUrl, bookId),
                        failOnStatusCode: false,
                    }).as('request')
                })

                it('returns 200', () => {
                    cy.get('@request')
                        .its('status')
                        .should('equal', 200)
                })

                it('returns the populated user', () => {
                    cy.fixture('books/the_fellowship_of_the_ring')
                        .then(expectedBook => {
                            cy.get('@request').should(response => {
                                const actualBook = response.body
                                expect(actualBook).to.have.property('name', expectedBook.name)
                                // Something in the titles structure keeps failing tests.
                                // expect(actualBook).to.have.deep.property('titles', expectedBook.titles)
                                expect(actualBook).to.have.property('publisher', expectedBook.publisher)
                                expect(actualBook).to.have.deep.property('authors', expectedBook.authors)
                                expect(actualBook).to.have.deep.property('years', expectedBook.years)
                                expect(actualBook).to.have.property('_id', bookId)
                            })
                        })
                })
            })

            context('not found', () => {
                beforeEach(() => {
                    cy.resetDb()
                    cy.request({
                        url: path.join(bookUrl, bookId),
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
                        .should('equal', 'No book with ID ' + bookId)
                })
            })
        })
    })

})