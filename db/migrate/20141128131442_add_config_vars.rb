class AddConfigVars < ActiveRecord::Migration
  def change
    add_column :apps, :config_vars, :text
    add_column :releases, :config_vars, :text
  end
end
