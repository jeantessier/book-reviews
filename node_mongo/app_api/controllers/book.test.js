require('dotenv').config({ path: '.env.test' })

const { ObjectId } = require("bson")
const { createBook } = require("../../test/fixtures/books")
const { createUserWithRole } = require("../../test/fixtures/users")

const mongoose = require("mongoose")
const db = require("../../test/db")
require("../models/book")
require("../models/review")
require("../models/user")
const Book = mongoose.model('Book')
const Review = mongoose.model('Review')
const User = mongoose.model('User')

const ctrlBook = require("./book")

const bookData = createBook()
const userData = createUserWithRole()

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
 * Book controller
 */
describe("Book controller", () => {

    //
    // list action
    //

    it("list sends an empty list when the repository is empty", async () => {
        // Given
        const mReq = {}
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.list(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith([])
    })

    it("list sends existing books", async () => {
        // Given
        await new Book(bookData).save()

        // and
        const mReq = {}
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.list(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith([expect.objectContaining({
            ... bookData,
            titles: bookData.titles.map(title => expect.objectContaining(title)),
            numReviews: 0,
        })])
    })

    it("list populates numReviews", async () => {
        // Given
        let userId
        await new User(userData).save().then(savedUser => userId = savedUser._id)
        let bookId
        await new Book(bookData).save().then(savedBook => bookId = savedBook._id)
        await new Review({ reviewer: userId, book: bookId, body: "body" }).save()

        // and
        const mReq = {}
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.list(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith([expect.objectContaining({
            ... bookData,
            titles: bookData.titles.map(title => expect.objectContaining(title)),
            numReviews: 1,
        })])
    })

    //
    // create action
    //

    it("create requires admin privileges", async () => {
        // Given
        const mReq = { currentUser: { admin: false } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(403)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/admin privileges/) })
    })

    it("create fails when name is missing", async () => {
        // Given
        const { name, ... partialBookData } = bookData
        const mReq = { currentUser: { admin: true }, body: partialBookData }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(400)
        expect(mRes.json).toBeCalledWith({ message: "All fields required" })
    })

    it("create fails when name is already taken", async () => {
        // Given
        await new Book(bookData).save()

        // and
        const mReq = { currentUser: { admin: true }, body: bookData }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(409)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/already a book named/) })
    })

    it("create succeeds to create a new book", async () => {
        // Given
        const mReq = { currentUser: { admin: true }, body: bookData }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(201)
        expect(mRes.json).toBeCalledWith(expect.objectContaining({
            ... bookData,
            titles: bookData.titles.map(title => expect.objectContaining(title)),
        }))
    })

    //
    // readOne action
    //

    it("readOne returns 400 if ID is not a valid ObjectId", async () => {
        // Given
        const invalidId = "this is not an ObjectId"
        const mReq = { params: { id: invalidId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(400)
        expect(mRes.json).toBeCalledWith(expect.any(mongoose.Error.CastError))
    })

    it("readOne returns 404 if ID is not found", async () => {
        // Given
        const notFoundId = new ObjectId()
        const mReq = { params: { id: notFoundId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(404)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(new RegExp(`No book with ID ${notFoundId}`)) })
    })

    it("readOne returns 200 if ID is found", async () => {
        // Given
        let bookId
        await new Book(bookData).save().then(savedBook => bookId = savedBook._id)

        // and
        const mReq = { params: { id: bookId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith(expect.objectContaining({
            ... bookData,
            titles: bookData.titles.map(title => expect.objectContaining(title)),
            numReviews: 0,
        }))
    })

    it("readOne populates numReviews", async () => {
        // Given
        let userId
        await new User(userData).save().then(savedUser => userId = savedUser._id)
        let bookId
        await new Book(bookData).save().then(savedBook => bookId = savedBook._id)
        await new Review({ reviewer: userId, book: bookId, body: "body" }).save()

        // and
        const mReq = { params: { id: bookId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlBook.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith(expect.objectContaining({
            ... bookData,
            titles: bookData.titles.map(title => expect.objectContaining(title)),
            numReviews: 1,
        }))
    })

})
