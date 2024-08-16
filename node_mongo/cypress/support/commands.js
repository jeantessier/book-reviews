// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

Cypress.Commands.add('resetDb', () => {
    cy.exec('echo \'db.reviews.deleteMany({}); db.books.deleteMany({}); db.users.deleteMany({})\' | docker compose exec -T mongo mongosh node_mongo_book_reviews_test')
})

Cypress.Commands.add('createUser', (name, email, password) => {
    cy.request('POST', Cypress.config('registerUrl'), { name, email, password })
})

Cypress.Commands.add('populateBook', book => {
    cy.exec(`echo 'db.books.insertOne(${JSON.stringify(book)})' | docker compose exec -T mongo mongosh node_mongo_book_reviews_test`)
})

Cypress.Commands.add('populateAllBooks', () => {
    [
        'books/the_hobbit',
        'books/the_lord_of_the_rings',
        'books/the_fellowship_of_the_ring',
        'books/the_two_towers',
        'books/the_return_of_the_king',
        'books/the_silmarillion'
    ].forEach(fixtureName => {
        cy.fixture(fixtureName).then(book => cy.populateBook(book))
    })
})

Cypress.Commands.add('populateUser', user => {
    const { password, ... userData } = { salt: user.password, hash: user.password, ... user }
    cy.exec(`echo 'db.users.insertOne(${JSON.stringify(userData)})' | docker compose exec -T mongo mongosh node_mongo_book_reviews_test`)
})

Cypress.Commands.add('populateAllUsers', () => {
    [
        'users/admin',
        'users/jean_tessier',
        'users/simon_tolkien'
    ].forEach(fixtureName => {
        cy.fixture(fixtureName).then(user => cy.populateUser(user))
    })
})

Cypress.Commands.add('grantRole', (email, role) => {
    cy.exec(`echo 'db.users.updateOne({email: "${email}"}, {$addToSet: {roles: "${role}"}})' | docker compose exec -T mongo mongosh node_mongo_book_reviews_test`)
})

Cypress.Commands.add('populateReview', review => {
    const { bookName, reviewerEmail, body, start, stop } = review
    // I have to use a heredoc because some review bodies contain "'" characters.
    cy.exec(`
docker compose exec -T mongo mongosh node_mongo_book_reviews_test << EOF
    db.reviews.insertOne({
        book: db.books.findOne({name: "${bookName}"})._id,
        reviewer: db.users.findOne({email: "${reviewerEmail}"})._id,
        body: ${JSON.stringify(body)},
        start: ${JSON.stringify(start)},
        stop: ${JSON.stringify(stop)}
    })
EOF
    `)
})

Cypress.Commands.add('populateAllReviews', () => {
    [
        'reviews/the_hobbit_by_jean_tessier',
        'reviews/the_hobbit_by_simon_tolkien',
        'reviews/the_lord_of_the_rings_by_jean_tessier',
        'reviews/the_fellowship_of_the_ring_by_jean_tessier',
        'reviews/the_two_towers_by_jean_tessier',
        'reviews/the_return_of_the_king_by_jean_tessier',
        'reviews/the_silmarillion_by_jean_tessier',
        'reviews/the_silmarillion_by_simon_tolkien'
    ].forEach(fixtureName => {
        cy.fixture(fixtureName).then(review => cy.populateReview(review))
    })
})
