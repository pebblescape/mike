class RenameProcInstancesToDynos < ActiveRecord::Migration
  def change
    rename_table :proc_instances, :dynos
  end
end
