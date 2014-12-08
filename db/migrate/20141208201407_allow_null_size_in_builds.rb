class AllowNullSizeInBuilds < ActiveRecord::Migration
  def change
    change_column :builds, :size, :integer, null: true
    change_column :builds, :process_types, :text, null: true
  end
end
