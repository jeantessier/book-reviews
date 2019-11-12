# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191111203725) do

  create_table "book_authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "book_id"
    t.string  "name",                null: false
    t.integer "order",   default: 0, null: false
    t.index ["book_id"], name: "index_book_authors_on_book_id", using: :btree
  end

  create_table "book_titles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "book_id"
    t.string  "title",                            null: false
    t.string  "link",    limit: 1023
    t.integer "order",                default: 0, null: false
    t.index ["book_id"], name: "index_book_titles_on_book_id", using: :btree
  end

  create_table "book_years", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "book_id"
    t.string  "year",                null: false
    t.integer "order",   default: 0, null: false
    t.index ["book_id"], name: "index_book_years_on_book_id", using: :btree
  end

  create_table "books", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       null: false
    t.string   "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_books_on_name", unique: true, using: :btree
  end

  create_table "reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "reviewer_id"
    t.integer  "book_id"
    t.text     "body",        limit: 65535, null: false
    t.date     "start"
    t.date     "stop"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["book_id"], name: "index_reviews_on_book_id", using: :btree
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "book_authors", "books"
  add_foreign_key "book_titles", "books"
  add_foreign_key "book_years", "books"
  add_foreign_key "reviews", "books", on_delete: :cascade
  add_foreign_key "reviews", "users", column: "reviewer_id", on_delete: :cascade
end
