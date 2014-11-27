class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys, id: :uuid do |t|
      t.string  :key, limit: 64, null: false
      t.uuid :user_id
      t.uuid :created_by_id
      
      t.timestamps
      
      t.index :key
      t.index :user_id, unique: true
    end
  end
end
