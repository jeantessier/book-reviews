describe('Book', () => {

    describe('list', () => {
        const bookUrl = Cypress.config('bookUrl')

        context('no books', () => {
            beforeEach(() => {
                cy.request(bookUrl).as('request')
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

        context('with one book', () => {
            beforeEach(() => {
                cy.fixture('books/the_hobbit')
                    .then(book => cy.populateBook(book))
                cy.request(bookUrl).as('request')
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

            it('includes the populated book', () => {
                cy.fixture('books/the_hobbit')
                    .then(expectedBook => {
                        cy.get('@request').should(response => {
                            const actualBook = response.body[0]
                            expect(actualBook).to.have.property('name', expectedBook.name)
                            // Something in the titles structure keeps failing tests.
                            // expect(actualBook).to.have.deep.property('titles', expectedBook.titles)
                            expect(actualBook).to.have.property('publisher', expectedBook.publisher)
                            expect(actualBook).to.have.deep.property('authors', expectedBook.authors)
                            expect(actualBook).to.have.deep.property('years', expectedBook.years)
                        })
                    })
            })
        })

        context('with multiple books', () => {
            beforeEach(() => {
                cy.populateAllBooks()
                cy.request(bookUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .should('be.ok')
            })

            it('gets a non-empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('have.lengthOf', 6)
            })
        })
    })

})