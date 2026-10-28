class CreateSubscriberSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriber_snapshots do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.date :recorded_on, null: false
      t.integer :count, null: false, default: 0

      t.timestamps
    end

    add_index :subscriber_snapshots, [ :workspace_id, :recorded_on ], unique: true

    add_check_constraint :subscriber_snapshots, "count >= 0", name: "subscriber_snapshots_count_non_negative"
  end
end
