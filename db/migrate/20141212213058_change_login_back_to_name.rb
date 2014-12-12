class ChangeLoginBackToName < ActiveRecord::Migration
  def change
    rename_column :users, :login, :name
    change_column :users, :name, :string, null: true
  end
end
