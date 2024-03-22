require('dotenv').config({ path: '.env.test' })

const mongoose = require("mongoose")
const db = require("../../test/db")
require("../models/book")
require("../models/review")
require("../models/user")
const Book = mongoose.model('Book')
const Review = mongoose.model('Review')
const User = mongoose.model('User')

const ctrlUser = require("./user")

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

const userData = {
    name: "First Last",
    email: "first_last@test.com",
    roles: ["ROLE_TEST_USER"],
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
 * User controller
 */
describe("User controller", () => {

    //
    // list action
    //

    it("list sends an empty list when the repository is empty", async () => {
        // Given
        const mReq = {}
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.list(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith([])
    })

    it("list sends existing users", async () => {
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
            numReviews: 0,
        })])
    })

    it("list populates numReviews", async () => {
        // Given
        let reviewer
        await new User(userData).save().then(savedUser => reviewer = savedUser._id)
        let book
        await new Book(bookData).save().then(savedBook => book = savedBook._id)
        await new Review({ reviewer, book, body: "body" }).save()

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

    //
    // create action
    //

    it("create requires admin privileges", async () => {
        // Given
        const mReq = { currentUser: { admin: false } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(403)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/admin privileges/) })
    })

    it("create fails when name is missing", async () => {
        // Given
        const { name, ... partialUserData } = { ... userData, password: "abcd1234" }
        const mReq = { currentUser: { admin: true }, body: partialUserData }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(400)
        expect(mRes.json).toBeCalledWith({ message: "All fields required" })
    })

    it("create fails when email is already taken", async () => {
        // Given
        await new User(userData).save()

        // and
        const mReq = { currentUser: { admin: true }, body: { ... userData, password: "abcd1234" } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(409)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(/already a user with/) })
    })

    it("create succeeds to create a new user", async () => {
        // Given
        const mReq = { currentUser: { admin: true }, body: { ... userData, password: "abcd1234" } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.create(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(201)
        expect(mRes.json).toBeCalledWith(expect.objectContaining({
            ... userData,
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
        await ctrlUser.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(400)
        expect(mRes.json).toBeCalledWith(expect.any(mongoose.Error.CastError))
    })

    it("readOne returns 404 if ID is not found", async () => {
        // Given
        const notFoundId = new mongoose.Schema.Types.ObjectId()
        const mReq = { params: { id: notFoundId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(404)
        expect(mRes.json).toBeCalledWith({ message: expect.stringMatching(new RegExp(`No user with ID ${notFoundId}`)) })
    })

    it("readOne returns 200 if ID is found", async () => {
        // Given
        let userId
        await new User(userData).save().then(savedUser => userId = savedUser._doc._id)

        // and
        const mReq = { params: { id: userId } }
        const mRes = { status: jest.fn().mockReturnThis(), json: jest.fn() }

        // When
        await ctrlUser.readOne(mReq, mRes)

        // Then
        expect(mRes.status).toBeCalledWith(200)
        expect(mRes.json).toBeCalledWith(expect.objectContaining({
            ... userData,
            numReviews: 0,
        }))
    })

    it("readOne populates numReviews", async () => {
        // Given
        let userId
        await new User(userData).save().then(savedUser => userId = savedUser._doc._id)
        let book
        await new Book(bookData).save().then(savedBook => book = savedBook._id)
        await new Review({ reviewer: userId, book, body: "body" }).save()

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
