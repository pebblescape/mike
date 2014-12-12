class CreateInstance < ActiveRecord::Migration
  def change
    create_table :instances, id: :uuid do |t|
      t.uuid      :user_id
      t.uuid      :app_id
      t.uuid      :build_id
      t.uuid      :release_id
      t.string    :type,        null: false
      t.integer   :port
      t.integer   :number
      t.string    :container_id
      t.inet      :ip_address
      t.datetime  :started_at

      t.timestamps

      t.index :user_id
      t.index :app_id
      t.index :build_id
      t.index :release_id
    end
  end
end
