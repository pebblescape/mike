class AddVersionToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :version, :integer, default: 1
  end
end
