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

ActiveRecord::Schema[8.1].define(version: 2026_11_14_233747) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "coach_posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "slug"
    t.string "title", limit: 256, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["slug"], name: "index_coach_posts_on_slug", unique: true
    t.index ["user_id"], name: "index_coach_posts_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "start_time", null: false
    t.string "title", limit: 256, null: false
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "mailing_lists", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "person_id"
    t.integer "team_id"
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_memberships_on_person_id"
    t.index ["team_id"], name: "index_memberships_on_team_id"
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "firstname", limit: 256, null: false
    t.string "gender"
    t.string "slug"
    t.string "surname", limit: 256, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "year"
    t.index ["slug"], name: "index_people_on_slug", unique: true
    t.index ["user_id"], name: "index_people_on_user_id", unique: true
  end

  create_table "person_claims", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "person_id", null: false
    t.datetime "reviewed_at"
    t.integer "reviewed_by_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["person_id"], name: "index_person_claims_on_person_id"
    t.index ["reviewed_by_id"], name: "index_person_claims_on_reviewed_by_id"
    t.index ["user_id"], name: "index_person_claims_on_pending_user_id", unique: true, where: "status = 'pending'"
    t.index ["user_id"], name: "index_person_claims_on_user_id"
  end

  create_table "person_relationships", force: :cascade do |t|
    t.integer "child_id"
    t.datetime "created_at", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", limit: 256, null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_races_on_event_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "bib"
    t.string "category"
    t.string "club"
    t.string "county"
    t.datetime "created_at", null: false
    t.integer "distance"
    t.integer "heat"
    t.string "name"
    t.integer "person_id"
    t.integer "position"
    t.integer "race_id", null: false
    t.string "result"
    t.decimal "seconds"
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_results_on_person_id"
    t.index ["race_id"], name: "index_results_on_race_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "time_trials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "distance"
    t.date "recorded_at", null: false
    t.string "surface"
    t.datetime "updated_at", null: false
  end

  create_table "tt_times", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "person_id", null: false
    t.decimal "seconds"
    t.integer "time_trial_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_tt_times_on_person_id"
    t.index ["time_trial_id"], name: "index_tt_times_on_time_trial_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "coach_posts", "users"
  add_foreign_key "memberships", "people"
  add_foreign_key "memberships", "teams"
  add_foreign_key "people", "users"
  add_foreign_key "person_claims", "people"
  add_foreign_key "person_claims", "users"
  add_foreign_key "person_claims", "users", column: "reviewed_by_id"
  add_foreign_key "posts", "users"
  add_foreign_key "races", "events"
  add_foreign_key "results", "races"
  add_foreign_key "tt_times", "people"
  add_foreign_key "tt_times", "time_trials"
end
