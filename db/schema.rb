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

ActiveRecord::Schema.define(version: 20170705102814) do

  create_table "commitments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id", null: false
    t.string "role", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_commitments_on_company_id"
    t.index ["user_id"], name: "index_commitments_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code"
    t.string "str_addr"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_companies_on_code", unique: true
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "supply_link", id: false, force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "provider_id", null: false
    t.index ["provider_id"], name: "index_supply_link_on_provider_id"
    t.index ["supplier_id"], name: "index_supply_link_on_supplier_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
