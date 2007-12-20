# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "comments", :force => true do |t|
    t.integer "entry_id"
    t.integer "user_id"
    t.text    "body"
  end

  create_table "entries", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "thumbnail"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flags", :force => true do |t|
    t.integer "entry_id"
    t.integer "user_id"
    t.string  "name"
    t.string  "value"
  end

  create_table "users", :force => true do |t|
    t.string "name"
    t.string "email"
    t.string "website"
    t.string "avatar"
  end

end
