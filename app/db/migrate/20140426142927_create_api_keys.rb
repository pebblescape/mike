class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string  :key, null: false, length: 64
      t.integer :user_id
      t.integer :created_by_id
      
      t.timestamps
      
      t.index :key
      t.index :user_id, unique: true
    end
  end
end
