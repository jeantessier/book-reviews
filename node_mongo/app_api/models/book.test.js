require('dotenv').config({ path: '.env.test' })

const mongoose = require("mongoose")
const db = require("../../test/db")
require("./book")
const Book = mongoose.model('Book')

const bookData = {
    name: "The_Hobbit",
    titles: [
        {
            title: "The Hobbit",
            link: "https://en.wikipedia.org/wiki/The_Hobbit",
        }, {
            title: "Bilbo le Hobbit",
            link: "https://fr.wikipedia.org/wiki/Le_Hobbit",
        }
    ],
    publisher: "Unwin & Allen",
    authors: ["J.R.R. Tolkien"],
    years: ["1937"],
}

beforeAll(async () => {
    await db.setUp()
})

afterEach(async () => {
    await db.dropCollections()
})

afterAll(async () => {
    await db.dropDatabase()
})

/**
 * Book model
 */
describe("Book model", () => {
    it("creates & saves book successfully", async () => {
        // Given
        const validBook = new Book(bookData)

        // When
        const savedBook = await validBook.save()

        // Then
        // Object Id should be defined when successfully saved to MongoDB.
        expect(savedBook._id).toBeDefined()
        expect(savedBook.name).toBe(bookData.name)
        expect(savedBook.titles).toEqual(
            bookData.titles.map(title => expect.objectContaining(title))
        )
        expect(savedBook.publisher).toBe(bookData.publisher)
        expect(savedBook.authors).toEqual(bookData.authors)
        expect(savedBook.years).toEqual(bookData.years)
    })

    // You shouldn't be able to add in any field that isn't defined in the schema
    it("creates book successfully, but the field not defined in schema should be undefined", async () => {
        // Given
        const bookWithInvalidField = new Book({
            ...bookData,
            nickname: "Def",
        })

        // When
        const savedBookWithInvalidField = await bookWithInvalidField.save()

        // Then
        expect(savedBookWithInvalidField._id).toBeDefined()
        expect(savedBookWithInvalidField.nickname).toBeUndefined()
    })

    it("does not create book without required field", async () => {
        // Given
        const { name, ... partialBookData } = bookData
        const bookWithoutRequiredField = new Book(partialBookData)

        // When
        let err
        try {
            await bookWithoutRequiredField.save()
        } catch (error) {
            err = error
        }

        // Then
        expect(err).toBeInstanceOf(mongoose.Error.ValidationError)
        expect(err.errors.name).toBeDefined()
    })

    it("does not create book if name is already taken", async () => {
        // Given
        const validBook = new Book(bookData)
        await validBook.save()
        const duplicateBook = new Book(bookData)

        // When
        let err
        try {
            await duplicateBook.save()
        } catch (error) {
            err = error
        }

        // Then
        expect(err).toBeDefined()
        expect(err.message).toMatch(/duplicate key error/)
    })
})
