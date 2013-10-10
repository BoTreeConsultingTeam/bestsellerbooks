# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20131010090152) do

  create_table "book_categories", :force => true do |t|
    t.text     "category"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "book_details", :force => true do |t|
    t.text     "images"
    t.string   "author"
    t.string   "title"
    t.string   "isbn"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "publisher"
    t.string   "language"
    t.text     "description"
  end

  create_table "book_meta", :force => true do |t|
    t.integer  "book_detail_id"
    t.integer  "site_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "price"
    t.integer  "discount"
    t.string   "book_detail_url"
    t.float    "rating"
  end

  create_table "category_details", :force => true do |t|
    t.integer  "book_category_id"
    t.integer  "book_detail_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end