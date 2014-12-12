class RenameInstanceToProcInstance < ActiveRecord::Migration
  def change
    rename_table :instances, :proc_instances
  end
end
