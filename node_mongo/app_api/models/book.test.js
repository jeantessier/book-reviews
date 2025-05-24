require('dotenv').config({ path: '.env.test' })

const { createBook } = require("../../test/fixtures/books")

const mongoose = require("mongoose")
const db = require("../../test/db")
require("./book")
const Book = mongoose.model('Book')

const bookData = createBook()

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
    describe('create', () => {
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

    describe('update', () => {
        it("adjusts timestamps", async () => {
            // Given
            const book = new Book(bookData)

            // And
            const savedBook = await book.save()
            const oldCreatedAt = savedBook.createdAt

            // When
            book.publisher = "New Publisher"
            const updatedBook = await book.save()

            // Then
            expect(updatedBook.createdAt).toBe(oldCreatedAt)
            expect(updatedBook.updatedAt.getTime()).toBeGreaterThan(oldCreatedAt.getTime())
        })

        it("no change does not change timestamps", async () => {
            // Given
            const book = new Book(bookData)

            // And
            const savedBook = await book.save()
            const oldCreatedAt = savedBook.createdAt

            // When
            const updatedBook = await book.save()

            // Then
            expect(updatedBook.createdAt).toBe(oldCreatedAt)
            expect(updatedBook.updatedAt).toBe(oldCreatedAt)
        })
    })
})
