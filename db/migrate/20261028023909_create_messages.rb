class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :workspace, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [ :workspace_id, :read_at ]
  end
end
