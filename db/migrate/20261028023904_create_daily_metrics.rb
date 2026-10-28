class CreateDailyMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_metrics do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.date :recorded_on, null: false
      t.integer :page_views, null: false, default: 0
      t.integer :sessions_count, null: false, default: 0
      t.integer :bounced_sessions, null: false, default: 0
      t.bigint :revenue_cents, null: false, default: 0

      t.timestamps
    end

    add_index :daily_metrics, [ :workspace_id, :recorded_on ], unique: true

    add_check_constraint :daily_metrics, "page_views >= 0", name: "daily_metrics_page_views_non_negative"
    add_check_constraint :daily_metrics, "sessions_count >= 0", name: "daily_metrics_sessions_non_negative"
    add_check_constraint :daily_metrics, "bounced_sessions >= 0", name: "daily_metrics_bounced_non_negative"
    add_check_constraint :daily_metrics, "bounced_sessions <= sessions_count", name: "daily_metrics_bounced_within_sessions"
    add_check_constraint :daily_metrics, "revenue_cents >= 0", name: "daily_metrics_revenue_non_negative"
  end
end
