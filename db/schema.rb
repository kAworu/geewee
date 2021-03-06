# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101105062323) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "persistence_token",   :null => false
    t.string   "single_access_token", :null => false
    t.string   "cached_slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "editor"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.string   "cached_slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",       :default => false
  end

  create_table "geewee_configs", :force => true do |t|
    t.string   "bloguri"
    t.string   "blogtitle"
    t.string   "blogsubtitle"
    t.boolean  "use_recaptcha",         :default => false
    t.string   "recaptcha_public_key"
    t.string   "recaptcha_private_key"
    t.integer  "post_count_per_page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "subtitle"
    t.text     "body"
    t.string   "cached_slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "author_id"
    t.integer  "category_id"
    t.string   "title"
    t.text     "intro"
    t.text     "body"
    t.boolean  "published"
    t.string   "cached_slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
