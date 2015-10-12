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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151012054750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string   "name",                  limit: 50, null: false
    t.text     "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "categorizations_count"
  end

  create_table "categorizations", force: true do |t|
    t.integer  "category_id", null: false
    t.integer  "repo_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorizations", ["category_id"], name: "index_categorizations_on_category_id", using: :btree
  add_index "categorizations", ["repo_id"], name: "index_categorizations_on_repo_id", using: :btree

  create_table "migration_info", id: false, force: true do |t|
    t.string "migration_name"
  end

  add_index "migration_info", ["migration_name"], name: "migration_name", unique: true, using: :btree

  create_table "releases", force: true do |t|
    t.string   "version",     null: false
    t.datetime "released_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repos", force: true do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "pushed_at"
    t.text     "source"
    t.text     "parent"
    t.text     "full_name"
    t.text     "most_recent_commit"
    t.text     "issues"
    t.boolean  "fork",                         default: false
    t.integer  "example_count",                default: 0
    t.boolean  "has_makefile"
    t.boolean  "has_correct_folder_structure"
    t.boolean  "has_thumbnail"
    t.integer  "user_id"
    t.integer  "release_id"
    t.string   "type",                         default: "Unsorted", null: false
    t.integer  "stargazers_count",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forks_count",                  default: 0
  end

  add_index "repos", ["full_name"], name: "index_repos_full_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider",                   null: false
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                      null: false
    t.string   "avatar_url"
    t.string   "location"
    t.boolean  "admin",      default: false
  end

  add_index "users", ["provider", "avatar_url"], name: "index_users_on_provider_and_avatar_url", unique: true, using: :btree
  add_index "users", ["provider", "login"], name: "index_users_on_provider_and_login", unique: true, using: :btree
  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree

  Foreigner.load
  add_foreign_key "categorizations", "categories", name: "categorizations_category_id_fk", dependent: :delete
  add_foreign_key "categorizations", "repos", name: "categorizations_repo_id_fk", dependent: :delete

  add_foreign_key "repos", "releases", name: "repos_release_id_fk", dependent: :delete
  add_foreign_key "repos", "users", name: "repos_user_id_fk", dependent: :delete

end
