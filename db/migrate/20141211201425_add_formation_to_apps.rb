class AddFormationToApps < ActiveRecord::Migration
  def change
    add_column :apps, :formation, :text
  end
end
