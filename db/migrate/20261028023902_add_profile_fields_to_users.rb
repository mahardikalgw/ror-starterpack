class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :string, null: false, default: "Business"
    add_reference :users, :workspace, null: false, foreign_key: { on_delete: :cascade }

    change_column_null :users, :name, false

    add_check_constraint :users, "length(name) <= 80", name: "users_name_length"
    add_check_constraint :users, "length(role) <= 40", name: "users_role_length"
  end
end
