class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name, null: false
      t.string :plan, null: false, default: "Team"
      t.string :currency, limit: 3, null: false, default: "USD"

      t.timestamps
    end

    add_index :workspaces, :name, unique: true
  end
end
