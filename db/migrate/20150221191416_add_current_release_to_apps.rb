class AddCurrentReleaseToApps < ActiveRecord::Migration
  def change
    add_column :apps, :current_release_id, :uuid
  end
end
