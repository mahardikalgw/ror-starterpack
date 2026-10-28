class AddLastActiveAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :last_active_at, :datetime
    add_index :sessions, :last_active_at

    change_column_null :sessions, :last_active_at, false
  end
end
