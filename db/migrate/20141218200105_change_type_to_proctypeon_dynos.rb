class ChangeTypeToProctypeonDynos < ActiveRecord::Migration
  def change
    rename_column :dynos, :type, :proctype
  end
end
