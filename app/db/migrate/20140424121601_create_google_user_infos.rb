class CreateGoogleUserInfos < ActiveRecord::Migration
  def change
    create_table :google_user_infos do |t|
      t.integer :user_id,         null: false
      t.string :google_user_id,   null: false
      t.string :name,             null: false
      t.string :first_name
      t.string :last_name

      t.timestamps

      t.index :google_user_id,  unique: true
      t.index :user_id,         unique: true
    end
  end
end
