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

ActiveRecord::Schema.define(version: 20141106050449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string "name",       limit: 50
    t.text   "login"
    t.text   "avatar_url"
  end

  create_table "categorizations", force: true do |t|
    t.integer  "category_id"
    t.integer  "repo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorizations", ["category_id"], name: "index_categorizations_on_category_id", using: :btree
  add_index "categorizations", ["repo_id"], name: "index_categorizations_on_repo_id", using: :btree

  create_table "contributors", force: true do |t|
    t.text "login"
    t.text "name"
    t.text "avatar_url"
    t.text "location"
  end

  create_table "migration_info", id: false, force: true do |t|
    t.string "migration_name"
  end

  add_index "migration_info", ["migration_name"], name: "migration_name", unique: true, using: :btree

  create_table "release_types", force: true do |t|
    t.integer  "release_id"
    t.integer  "repo_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "release_types", ["release_id"], name: "index_release_types_on_release_id", using: :btree
  add_index "release_types", ["repo_id"], name: "index_release_types_on_repo_id", using: :btree

  create_table "releases", force: true do |t|
    t.string   "version"
    t.datetime "released_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repos", force: true do |t|
    t.text     "name"
    t.text     "owner"
    t.text     "description"
    t.datetime "last_pushed_at"
    t.datetime "github_created_at"
    t.text     "source"
    t.text     "parent"
    t.text     "github_slug"
    t.boolean  "not_addon",                    default: false
    t.boolean  "incomplete",                   default: false
    t.integer  "category_id"
    t.text     "readme"
    t.text     "forks"
    t.text     "most_recent_commit"
    t.text     "issues"
    t.boolean  "is_fork",                      default: false
    t.boolean  "has_forks"
    t.boolean  "deleted"
    t.integer  "followers"
    t.text     "github_pushed_at"
    t.text     "owner_avatar"
    t.integer  "example_count"
    t.boolean  "has_makefile"
    t.boolean  "has_correct_folder_structure"
    t.boolean  "has_thumbnail"
    t.integer  "user_id"
    t.integer  "contributor_id"
    t.boolean  "updated",                      default: false
    t.string   "type",                         default: "Unsorted", null: false
  end

  add_index "repos", ["category_id"], name: "index_repos_category", using: :btree

  create_table "users", force: true do |t|
    t.string "username", limit: 50
    t.string "password", limit: 50
  end

  Foreigner.load
  add_foreign_key "categorizations", "categories", name: "categorizations_category_id_fk"
  add_foreign_key "categorizations", "repos", name: "categorizations_repo_id_fk"

  add_foreign_key "release_types", "releases", name: "release_types_release_id_fk"
  add_foreign_key "release_types", "repos", name: "release_types_repo_id_fk"

end
