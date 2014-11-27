class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :app_id
      t.integer :status,                null: false
      t.string  :buildpack_description
      t.string  :commit
      t.text    :process_types,         null: false
      t.integer :size,                  null: false
      
      t.timestamps
      
      t.index :user_id
      t.index :app_id
    end
  end
end
