class CreateChannelRevenues < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_revenues do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.date :recorded_on, null: false
      t.string :channel, null: false
      t.bigint :amount_cents, null: false, default: 0

      t.timestamps
    end

    add_index :channel_revenues, [ :workspace_id, :recorded_on, :channel ], unique: true

    add_check_constraint :channel_revenues, "amount_cents >= 0", name: "channel_revenues_amount_non_negative"
    add_check_constraint :channel_revenues, "channel IN ('website','mobile_app','other')", name: "channel_revenues_channel_allowed"
  end
end
