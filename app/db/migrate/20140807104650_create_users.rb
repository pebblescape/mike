class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :email,         null: false
      t.string  :password_hash, limit: 64
      t.string  :salt,          limit: 32
      t.string  :auth_token,    limit: 32
      t.boolean :admin,         null: false, default: false
      t.boolean :active,        null: false, default: false
      
      t.timestamps
      
      t.index :auth_token
      t.index :email, unique: true
    end
  end
end
