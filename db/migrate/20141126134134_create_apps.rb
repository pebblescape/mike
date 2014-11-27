class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps, id: :uuid do |t|
      t.uuid :owner_id
      t.string :name, null: false
      
      t.timestamps
      
      t.index :name
    end
  end
end
