# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_14_213031) do
  create_table "activities", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at"
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_activities_on_issue_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_assignments_on_issue_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "file_path"
    t.integer "issue_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_attachments_on_issue_id"
    t.index ["user_id"], name: "index_attachments_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "issue_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_comments_on_issue_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "issue_tags", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "tag_id", null: false
    t.index ["issue_id"], name: "index_issue_tags_on_issue_id"
    t.index ["tag_id"], name: "index_issue_tags_on_tag_id"
  end

  create_table "issues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.datetime "deadline"
    t.text "description"
    t.integer "priority_id"
    t.integer "severity_id"
    t.integer "status_id"
    t.string "subject"
    t.integer "type_id"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_issues_on_creator_id"
    t.index ["priority_id"], name: "index_issues_on_priority_id"
    t.index ["severity_id"], name: "index_issues_on_severity_id"
    t.index ["status_id"], name: "index_issues_on_status_id"
    t.index ["type_id"], name: "index_issues_on_type_id"
  end

  create_table "priorities", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "severities", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "types", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "watchers", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_watchers_on_issue_id"
    t.index ["user_id"], name: "index_watchers_on_user_id"
  end

  add_foreign_key "activities", "issues"
  add_foreign_key "activities", "users"
  add_foreign_key "assignments", "issues"
  add_foreign_key "assignments", "users"
  add_foreign_key "attachments", "issues"
  add_foreign_key "attachments", "users"
  add_foreign_key "comments", "issues"
  add_foreign_key "comments", "users"
  add_foreign_key "issue_tags", "issues"
  add_foreign_key "issue_tags", "tags"
  add_foreign_key "issues", "priorities"
  add_foreign_key "issues", "severities"
  add_foreign_key "issues", "statuses"
  add_foreign_key "issues", "types"
  add_foreign_key "issues", "users", column: "creator_id"
  add_foreign_key "watchers", "issues"
  add_foreign_key "watchers", "users"
end
