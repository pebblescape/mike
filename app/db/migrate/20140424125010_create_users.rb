class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :username,        null: false,  length: 60
      t.string    :username_lower,  null: false,  length: 60
      t.string    :name,                          length: 255
      t.string    :email,                         length: 256
      t.string    :password_hash,                 length: 64
      t.string    :salt,                          length: 32      
      t.string    :auth_token,                    length: 32
      t.boolean   :admin,           null: false,  default: false
      t.datetime  :last_seen_at
      t.datetime  :previous_visit_at
      t.inet      :ip_address
      t.string    :locale, length: 10
      
      t.index :auth_token
      t.index :email, unique: true
      t.index :username, unique: true
      t.index :username_lower, unique: true
    end
  end
end
