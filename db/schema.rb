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

ActiveRecord::Schema.define(:version => 20131031092000) do

  create_table "book_categories", :force => true do |t|
    t.text     "category_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "book_details", :force => true do |t|
    t.text     "images"
    t.string   "author"
    t.string   "title"
    t.string   "isbn"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "publisher"
    t.string   "language"
    t.text     "description"
    t.float    "average_rating"
    t.integer  "occurrence"
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
    t.integer  "rating_count"
    t.string   "delivery_days"
  end

  add_index "book_meta", ["book_detail_id", "site_id"], :name => "index_book_meta_on_book_detail_id_and_site_id", :unique => true

  create_table "category_details", :force => true do |t|
    t.integer  "book_category_id"
    t.integer  "book_detail_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "guest_posts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
