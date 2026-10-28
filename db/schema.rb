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

ActiveRecord::Schema[8.1].define(version: 2026_10_28_023909) do
  create_table "channel_revenues", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.date "recorded_on", null: false
    t.string "channel", null: false
    t.bigint "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "recorded_on", "channel"], name: "idx_on_workspace_id_recorded_on_channel_a365d556bc", unique: true
    t.index ["workspace_id"], name: "index_channel_revenues_on_workspace_id"
    t.check_constraint "amount_cents >= 0", name: "channel_revenues_amount_non_negative"
    t.check_constraint "channel IN ('website','mobile_app','other')", name: "channel_revenues_channel_allowed"
  end

  create_table "daily_metrics", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.date "recorded_on", null: false
    t.integer "page_views", default: 0, null: false
    t.integer "sessions_count", default: 0, null: false
    t.integer "bounced_sessions", default: 0, null: false
    t.bigint "revenue_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "recorded_on"], name: "index_daily_metrics_on_workspace_id_and_recorded_on", unique: true
    t.index ["workspace_id"], name: "index_daily_metrics_on_workspace_id"
    t.check_constraint "bounced_sessions <= sessions_count", name: "daily_metrics_bounced_within_sessions"
    t.check_constraint "bounced_sessions >= 0", name: "daily_metrics_bounced_non_negative"
    t.check_constraint "page_views >= 0", name: "daily_metrics_page_views_non_negative"
    t.check_constraint "revenue_cents >= 0", name: "daily_metrics_revenue_non_negative"
    t.check_constraint "sessions_count >= 0", name: "daily_metrics_sessions_non_negative"
  end

  create_table "integrations", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.integer "rate", default: 0, null: false
    t.bigint "profit_cents", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "name"], name: "index_integrations_on_workspace_id_and_name", unique: true
    t.index ["workspace_id", "position"], name: "index_integrations_on_workspace_id_and_position"
    t.index ["workspace_id"], name: "index_integrations_on_workspace_id"
    t.check_constraint "position >= 0", name: "integrations_position_non_negative"
    t.check_constraint "profit_cents >= 0", name: "integrations_profit_non_negative"
    t.check_constraint "rate BETWEEN 0 AND 100", name: "integrations_rate_range"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "read_at"], name: "index_messages_on_workspace_id_and_read_at"
    t.index ["workspace_id"], name: "index_messages_on_workspace_id"
  end

  create_table "sales_records", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.date "recorded_on", null: false
    t.string "region", null: false
    t.bigint "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "recorded_on", "region"], name: "index_sales_records_on_workspace_id_and_recorded_on_and_region", unique: true
    t.index ["workspace_id", "recorded_on"], name: "index_sales_records_on_workspace_id_and_recorded_on"
    t.index ["workspace_id", "region", "recorded_on"], name: "index_sales_records_on_workspace_id_and_region_and_recorded_on"
    t.index ["workspace_id"], name: "index_sales_records_on_workspace_id"
    t.check_constraint "amount_cents >= 0", name: "sales_records_amount_non_negative"
    t.check_constraint "region IN ('china','eu','usa','canada','other')", name: "sales_records_region_allowed"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_active_at", null: false
    t.index ["last_active_at"], name: "index_sessions_on_last_active_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subscriber_snapshots", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.date "recorded_on", null: false
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "recorded_on"], name: "index_subscriber_snapshots_on_workspace_id_and_recorded_on", unique: true
    t.index ["workspace_id"], name: "index_subscriber_snapshots_on_workspace_id"
    t.check_constraint "count >= 0", name: "subscriber_snapshots_count_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "role", default: "Business", null: false
    t.integer "workspace_id", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
    t.check_constraint "length(name) <= 80", name: "users_name_length"
    t.check_constraint "length(role) <= 40", name: "users_role_length"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.string "plan", default: "Team", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workspaces_on_name", unique: true
  end

  add_foreign_key "channel_revenues", "workspaces", on_delete: :cascade
  add_foreign_key "daily_metrics", "workspaces", on_delete: :cascade
  add_foreign_key "integrations", "workspaces", on_delete: :cascade
  add_foreign_key "messages", "workspaces", on_delete: :cascade
  add_foreign_key "sales_records", "workspaces", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "subscriber_snapshots", "workspaces", on_delete: :cascade
  add_foreign_key "users", "workspaces", on_delete: :cascade
end
