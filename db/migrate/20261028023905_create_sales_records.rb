class CreateSalesRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_records do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.date :recorded_on, null: false
      t.string :region, null: false
      t.bigint :amount_cents, null: false, default: 0

      t.timestamps
    end

    add_index :sales_records, [ :workspace_id, :recorded_on ]
    add_index :sales_records, [ :workspace_id, :region, :recorded_on ]
    add_index :sales_records, [ :workspace_id, :recorded_on, :region ], unique: true

    add_check_constraint :sales_records, "amount_cents >= 0", name: "sales_records_amount_non_negative"
    add_check_constraint :sales_records, "region IN ('china','eu','usa','canada','other')", name: "sales_records_region_allowed"
  end
end
