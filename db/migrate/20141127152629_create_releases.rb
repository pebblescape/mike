class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :app_id
      t.uuid :build_id
      t.integer :version,     null: false
      t.string  :description, null: false
      
      t.timestamps
      
      t.index :user_id
      t.index :app_id
      t.index :build_id
    end
  end
end
