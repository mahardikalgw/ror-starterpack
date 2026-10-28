class CreateIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :integrations do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :category, null: false
      t.integer :rate, null: false, default: 0
      t.bigint :profit_cents, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :integrations, [ :workspace_id, :name ], unique: true
    add_index :integrations, [ :workspace_id, :position ]

    add_check_constraint :integrations, "rate BETWEEN 0 AND 100", name: "integrations_rate_range"
    add_check_constraint :integrations, "profit_cents >= 0", name: "integrations_profit_non_negative"
    add_check_constraint :integrations, "position >= 0", name: "integrations_position_non_negative"
  end
end
