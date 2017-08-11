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

ActiveRecord::Schema.define(version: 20170731100456) do

  create_table "commitments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "pending_admin_conf", default: true, null: false
    t.boolean "pending_member_conf", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_commitments_on_company_id"
    t.index ["user_id", "company_id"], name: "index_commitments_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_commitments_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "str_addr"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_companies_on_code", unique: true
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "ref_code"
    t.integer "price", null: false
    t.string "unit_size", null: false
    t.integer "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "supplier_id"], name: "index_items_on_name_and_supplier_id", unique: true
    t.index ["ref_code", "supplier_id"], name: "index_items_on_ref_code_and_supplier_id", unique: true
    t.index ["supplier_id"], name: "index_items_on_supplier_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "item_id", null: false
    t.integer "qty", default: 1, null: false
    t.integer "price", null: false
    t.integer "line_total", null: false
    t.boolean "comped", default: false, null: false
    t.integer "qty_disputed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_line_items_on_item_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "purchaser_id", null: false
    t.integer "placed_by_id", null: false
    t.integer "accepted_by_id"
    t.string "invoice_no", null: false
    t.integer "total"
    t.integer "discount"
    t.string "discount_type"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_orders_on_accepted_by_id"
    t.index ["placed_by_id"], name: "index_orders_on_placed_by_id"
    t.index ["purchaser_id"], name: "index_orders_on_purchaser_id"
    t.index ["supplier_id"], name: "index_orders_on_supplier_id"
    t.index [nil, "invoice_no"], name: "index_orders_on_supplier_and_invoice_no", unique: true
  end

  create_table "supply_links", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "purchaser_id", null: false
    t.boolean "pending_supplier_conf", default: true, null: false
    t.boolean "pending_purchaser_conf", default: true, null: false
    t.index ["purchaser_id"], name: "index_supply_links_on_purchaser_id"
    t.index ["supplier_id"], name: "index_supply_links_on_supplier_id"
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
