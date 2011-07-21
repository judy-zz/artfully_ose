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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110721183401) do

  create_table "bank_accounts", :force => true do |t|
    t.string   "routing_number"
    t.string   "number"
    t.string   "account_type"
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donations", :force => true do |t|
    t.integer  "amount"
    t.integer  "order_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kits", :force => true do |t|
    t.string   "state"
    t.string   "type"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "orders", :force => true do |t|
    t.string   "state"
    t.string   "transaction_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "time_zone"
    t.string   "legal_organization_name"
    t.string   "ein"
    t.string   "fa_member_id"
    t.string   "fa_project_id"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchasable_tickets", :force => true do |t|
    t.integer  "order_id"
    t.string   "ticket_id"
    t.string   "lock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => ""
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask"
    t.string   "customer_id"
    t.datetime "suspended_at"
    t.string   "suspension_reason"
    t.string   "invitation_token",     :limit => 60
    t.datetime "invitation_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
