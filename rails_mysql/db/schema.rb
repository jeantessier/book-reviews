# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_15_061855) do

  create_table "book_authors", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "book_id"
    t.string "author", null: false
    t.integer "order", default: 0, null: false
    t.index ["book_id"], name: "index_book_authors_on_book_id"
  end

  create_table "book_titles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "book_id"
    t.string "title", null: false
    t.string "link", limit: 1023
    t.integer "order", default: 0, null: false
    t.index ["book_id"], name: "index_book_titles_on_book_id"
  end

  create_table "book_years", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "book_id"
    t.string "year", null: false
    t.integer "order", default: 0, null: false
    t.index ["book_id"], name: "index_book_years_on_book_id"
  end

  create_table "books", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_books_on_name", unique: true
  end

  create_table "reviews", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "reviewer_id"
    t.integer "book_id"
    t.text "body", null: false
    t.date "start"
    t.date "stop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_reviews_on_book_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "book_authors", "books"
  add_foreign_key "book_titles", "books"
  add_foreign_key "book_years", "books"
  add_foreign_key "reviews", "books"
  add_foreign_key "reviews", "users", column: "reviewer_id"
end
