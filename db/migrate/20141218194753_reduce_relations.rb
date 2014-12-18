class ReduceRelations < ActiveRecord::Migration
  def change
    remove_column :dynos, :build_id
    remove_column :dynos, :user_id
  end
end
