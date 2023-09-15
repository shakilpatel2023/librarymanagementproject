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

ActiveRecord::Schema[7.0].define(version: 2023_09_14_131736) do
  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "ISBN"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "book_quantity"
  end

  create_table "patrons", force: :cascade do |t|
    t.string "name"
    t.integer "contact_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date"
    t.date "return_date"
    t.integer "patron_id", null: false
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "late_fee"
    t.index ["book_id"], name: "index_transactions_on_book_id"
    t.index ["patron_id"], name: "index_transactions_on_patron_id"
  end

  add_foreign_key "transactions", "books"
  add_foreign_key "transactions", "patrons"
end
