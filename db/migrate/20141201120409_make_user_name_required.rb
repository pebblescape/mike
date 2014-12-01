class MakeUserNameRequired < ActiveRecord::Migration
  def change
    change_column :users, :name, :string, null: false
    add_index :users, :name, unique: true
  end
end
