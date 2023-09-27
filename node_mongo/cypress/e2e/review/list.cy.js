describe('Review', () => {

    describe('list', () => {
        const reviewUrl = Cypress.config('reviewUrl')

        context('no reviews', () => {
            beforeEach(() => {
                cy.request(reviewUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 200)
            })

            it('gets an empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('be.empty')
            })
        })

        context('with one review', () => {
            beforeEach(() => {
                cy.fixture('books/the_hobbit')
                    .then(book => cy.populateBook(book))
                cy.fixture('users/jean_tessier')
                    .then(user => cy.populateUser(user))
                cy.fixture('reviews/the_hobbit_by_jean_tessier')
                    .then(review => cy.populateReview(review))
                cy.request(reviewUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 200)
            })

            it('gets a non-empty array', () => {
                cy.get('@request')
                    .its('body')
                    .should('have.lengthOf', 1)
            })

            it('includes the populated review', () => {
                cy.fixture('reviews/the_hobbit_by_jean_tessier')
                    .then(expectedReview => {
                        cy.get('@request').should(response => {
                            const actualReview = response.body[0]
                            expect(actualReview).to.have.property('body', expectedReview.body)
                            expect(actualReview).to.have.property('start', new Date(expectedReview.start).toISOString())
                            expect(actualReview).to.have.property('stop', new Date(expectedReview.stop).toISOString())
                            expect(actualReview).to.have.property('_id')
                            expect(actualReview).to.not.have.property('bookName')
                            expect(actualReview).to.not.have.property('reviewerEmail')
                        })
                    })
            })
        })

        context('with multiple reviews', () => {
            beforeEach(() => {
                cy.populateAllBooks()
                cy.populateAllUsers()
                cy.populateAllReviews()
                cy.request(reviewUrl).as('request')
            })

            it('returns 200', () => {
                cy.get('@request')
                    .its('status')
                    .should('equal', 200)
            })

            it('gets all the reviews', () => {
                cy.get('@request')
                    .its('body')
                    .should('have.lengthOf', 8)
            })
        })
    })

})