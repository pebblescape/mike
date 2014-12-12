class AddImageIdToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :image_id, :string
  end
end
