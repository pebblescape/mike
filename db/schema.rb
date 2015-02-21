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

ActiveRecord::Schema.define(version: 20150221200326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "api_keys", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "key",           limit: 64, null: false
    t.uuid     "user_id"
    t.uuid     "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", unique: true, using: :btree

  create_table "apps", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "owner_id"
    t.string   "name",               limit: 255,                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "config_vars",                    default: {}
    t.hstore   "formation",                      default: {"web"=>"1"}
    t.uuid     "current_release_id"
  end

  add_index "apps", ["name"], name: "index_apps_on_name", using: :btree
  add_index "apps", ["owner_id"], name: "index_apps_on_owner_id", using: :btree

  create_table "builds", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "app_id"
    t.integer  "status",                                         null: false
    t.string   "buildpack_description", limit: 255
    t.string   "commit",                limit: 255
    t.hstore   "process_types",                     default: {}
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_id",              limit: 255
  end

  add_index "builds", ["app_id"], name: "index_builds_on_app_id", using: :btree
  add_index "builds", ["user_id"], name: "index_builds_on_user_id", using: :btree

  create_table "dynos", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "app_id"
    t.uuid     "release_id"
    t.string   "proctype",     limit: 255, null: false
    t.integer  "port"
    t.integer  "number"
    t.string   "container_id", limit: 255
    t.inet     "ip_address"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dynos", ["app_id"], name: "index_dynos_on_app_id", using: :btree
  add_index "dynos", ["release_id"], name: "index_dynos_on_release_id", using: :btree

  create_table "releases", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "app_id"
    t.uuid     "build_id"
    t.string   "description", limit: 255,              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "config_vars",             default: {}
    t.integer  "version",                 default: 1
  end

  add_index "releases", ["app_id"], name: "index_releases_on_app_id", using: :btree
  add_index "releases", ["build_id"], name: "index_releases_on_build_id", using: :btree
  add_index "releases", ["user_id"], name: "index_releases_on_user_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "email",         limit: 255,                 null: false
    t.string   "password_hash", limit: 64
    t.string   "salt",          limit: 32
    t.string   "auth_token",    limit: 32
    t.boolean  "admin",                     default: false, null: false
    t.boolean  "active",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree

end
