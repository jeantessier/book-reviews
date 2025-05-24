require('dotenv').config({ path: '.env.test' })

const { ObjectId } = require("bson")
const { faker } = require('@faker-js/faker')
const { createBook } = require('../../test/fixtures/books')
const { createUserWithRole } = require('../../test/fixtures/users')

const mongoose = require("mongoose")
const db = require("../../test/db")
require("../models/book")
require("../models/review")
require("../models/user")
const Book = mongoose.model('Book')
const Review = mongoose.model('Review')
const User = mongoose.model('User')

const ctrlUser = require("./user")

const bookData = createBook()
const userData = createUserWithRole()
const password = faker.internet.password()

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
 * User controller
 */
describe("User controller", () => {

    describe("list action", () => {
        it("sends an empty list when the repository is empty", async () => {
            // Given
            const mReq = {}
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.list(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(200)
            expect(mRes.json).toBeCalledWith([])
        })

        it("sends existing users", async () => {
            // Given
            await new User(userData).save()

            // and
            const mReq = {}
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.list(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(200)
            expect(mRes.json).toBeCalledWith([expect.objectContaining({
                ... userData,
                createdAt: expect.any(Date),
                updatedAt: expect.any(Date),
                numReviews: 0,
            })])
        })

        it("populates numReviews", async () => {
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
            await ctrlUser.list(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(200)
            expect(mRes.json).toBeCalledWith([expect.objectContaining({
                ... userData,
                numReviews: 1,
            })])
        })
    })

    describe("create action", () => {
        it("requires admin privileges", async () => {
            // Given
            const mReq = { currentUser: { admin: false } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.create(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(403)
            expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/admin privileges/) })
        })

        it("fails when name is missing", async () => {
            // Given
            const { name, ... partialUserData } = { ... userData, password }
            const mReq = { currentUser: { admin: true }, body: partialUserData }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.create(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(400)
            expect(mRes.json).toBeCalledWith({ message: "All fields required" })
        })

        it("fails when email is already taken", async () => {
            // Given
            await new User(userData).save()

            // and
            const mReq = { currentUser: { admin: true }, body: { ... userData, password } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.create(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(409)
            expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/already a user with/) })
        })

        it("succeeds to create a new user", async () => {
            // Given
            const mReq = { currentUser: { admin: true }, body: { ... userData, password } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.create(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(201)
            expect(mRes.json).toBeCalledWith(expect.objectContaining({
                ... userData,
                createdAt: expect.any(Date),
                updatedAt: expect.any(Date),
            }))
        })
    })

    describe("readOne action", () => {
        it("returns 400 if ID is not a valid ObjectId", async () => {
            // Given
            const invalidId = "this is not an ObjectId"
            const mReq = { params: { id: invalidId } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.readOne(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(400)
            expect(mRes.json).toBeCalledWith(expect.any(mongoose.Error.CastError))
        })

        it("returns 404 if ID is not found", async () => {
            // Given
            const notFoundId = new ObjectId()
            const mReq = { params: { id: notFoundId } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.readOne(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(404)
            expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(new RegExp(`No user with ID ${notFoundId}`)) })
        })

        it("returns 200 if ID is found", async () => {
            // Given
            let userId
            await new User(userData).save().then(savedUser => userId = savedUser._id)

            // and
            const mReq = { params: { id: userId } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.readOne(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(200)
            expect(mRes.json).toBeCalledWith(expect.objectContaining({
                ... userData,
                createdAt: expect.any(Date),
                updatedAt: expect.any(Date),
                numReviews: 0,
            }))
        })

        it("populates numReviews", async () => {
            // Given
            let userId
            await new User(userData).save().then(savedUser => userId = savedUser._id)
            let bookId
            await new Book(bookData).save().then(savedBook => bookId = savedBook._id)
            await new Review({ reviewer: userId, book: bookId, body: "body" }).save()

            // and
            const mReq = { params: { id: userId } }
            const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

            // When
            await ctrlUser.readOne(mReq, mRes)

            // Then
            expect(mRes.status).toBeCalledWith(200)
            expect(mRes.json).toBeCalledWith(expect.objectContaining({
                ... userData,
                numReviews: 1,
            }))
        })
    })

})
