class CreateSshKeys < ActiveRecord::Migration
  def change
    create_table :ssh_keys do |t|
      t.integer :user_id
      t.text    :key,     null: false
      
      t.timestamps
      
      t.index :key
    end
  end
end
