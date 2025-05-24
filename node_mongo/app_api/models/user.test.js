require('dotenv').config({ path: '.env.test' })

const { ObjectId } = require("bson")
const { createUserWithPassword } = require("../../test/fixtures/users")

const mongoose = require("mongoose")
const db = require("../../test/db")
require("./user")
const User = mongoose.model('User')

const userData = createUserWithPassword()

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
    describe('create', () => {
        it("creates & saves user successfully", async () => {
            // Given
            const validUser = new User(userData)
            validUser.setPassword(userData.password)

            // When
            const savedUser = await validUser.save()

            // Then
            // Object Id should be defined when successfully saved to MongoDB.
            expect(savedUser._id).toBeDefined()
            expect(savedUser.name).toBe(userData.name)
            expect(savedUser.email).toBe(userData.email)
            expect(savedUser.salt).toBeDefined()
            expect(savedUser.hash).toBeDefined()
            expect(savedUser.password).toBeUndefined()
            expect(savedUser.createdAt).toBeDefined()
            expect(savedUser.updatedAt).toBe(savedUser.createdAt)
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

        it("does not create user if email is already taken", async () => {
            // Given
            const validUser = new User(userData)
            validUser.setPassword(userData.password)
            await validUser.save()
            const duplicateUser = new User(userData)
            duplicateUser.setPassword(userData.password)

            // When
            let err
            try {
                await duplicateUser.save()
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
            const user = new User(userData)
            user.setPassword(userData.password)

            // And
            const savedUser = await user.save()
            const oldCreatedAt = savedUser.createdAt

            // When
            user.name = "New Name"
            const updatedUser = await user.save()

            // Then
            expect(updatedUser.createdAt).toBe(oldCreatedAt)
            expect(updatedUser.updatedAt.getTime()).toBeGreaterThan(oldCreatedAt.getTime())
        })

        it("no change does not change timestamps", async () => {
            // Given
            const user = new User(userData)
            user.setPassword(userData.password)

            // And
            const savedUser = await user.save()
            const oldCreatedAt = savedUser.createdAt

            // When
            const updatedUser = await user.save()

            // Then
            expect(updatedUser.createdAt).toBe(oldCreatedAt)
            expect(updatedUser.updatedAt).toBe(oldCreatedAt)
        })
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
