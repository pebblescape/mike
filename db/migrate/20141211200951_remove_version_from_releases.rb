class RemoveVersionFromReleases < ActiveRecord::Migration
  def change
    remove_column :releases, :version
  end
end
