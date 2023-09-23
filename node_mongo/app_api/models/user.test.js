require('dotenv').config({ path: '.env.test' })

const mongoose = require("mongoose")
const db = require("../../test/db")
require("./user")
const User = mongoose.model('User')

const userData = {
    name: "Abc",
    email: "abc@bookreviews.com",
    password: "abcd1234",
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
 * User model
 */
describe("User model", () => {
    it("creates & saves user successfully", async () => {
        // Given
        const validUser = new User(userData)
        validUser.setPassword(userData.password)

        // When
        const savedUser = await validUser.save()

        // Then
        // Object Id should be defined when successfully saved to MongoDB.
        expect(savedUser._id).toBeDefined()
        expect(savedUser.email).toBe(userData.email)
        expect(savedUser.phone).toBe(userData.phone)
        expect(savedUser.salt).toBeDefined()
        expect(savedUser.hash).toBeDefined()
    })

    // You shouldn't be able to add in any field that isn't defined in the schema
    it("creates user successfully, but the field not defined in schema should be undefined", async () => {
        // Given
        const userWithInvalidField = new User({
            ...userData,
            nickname: "Def",
        })
        await userWithInvalidField.setPassword(userData.password)

        // When
        const savedUserWithInvalidField = await userWithInvalidField.save()

        // Then
        expect(savedUserWithInvalidField._id).toBeDefined()
        expect(savedUserWithInvalidField.nickname).toBeUndefined()
    })

    it("does not create user without required field", async () => {
        // Given
        const userWithoutRequiredField = new User({ name: userData.name })

        // When
        let err
        try {
            await userWithoutRequiredField.save()
        } catch (error) {
            err = error
        }

        // Then
        expect(err).toBeInstanceOf(mongoose.Error.ValidationError)
        expect(err.errors.email).toBeDefined()
    })

    describe('generateJwt', () => {
        it("generates a JWT", async () => {
            // Given
            const user = new User(userData)
            user.setPassword(userData.password)
            const savedUser = await user.save()

            // When
            const jwt = savedUser.generateJwt()

            // Then
            expect(jwt).toMatch(/\w+\.\w+\.\w+/)
        })
    })

    describe('validatePassword', () => {
        it("validates the correct password", async () => {
            // Given
            const user = new User(userData)
            user.setPassword(userData.password)
            const savedUser = await user.save()

            // When
            const result = savedUser.validPassword(userData.password)

            // Then
            expect(result).toBeTruthy()
        })

        it("fails with the wrong password", async () => {
            // Given
            const user = new User(userData)
            user.setPassword(userData.password)
            const savedUser = await user.save()

            // When
            const result = savedUser.validPassword('wrong password')

            // Then
            expect(result).toBeFalsy()
        })
    })
})
