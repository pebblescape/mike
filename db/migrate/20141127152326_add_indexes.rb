class AddIndexes < ActiveRecord::Migration
  def change
    add_index :apps, :owner_id
    add_index :ssh_keys, :user_id
  end
end
