class ChangeFormationsAndConfigVarsToHstore < ActiveRecord::Migration
  def up
    change_column :apps, :formation, 'hstore USING hstore(ARRAY[\'web\',\'1\'])', default: {web: 1}
    change_column :apps, :config_vars, 'hstore USING \'\'', default: {}
    change_column :releases, :config_vars, 'hstore USING \'\'', default: {}
    change_column :builds, :process_types, 'hstore USING \'\'', default: {}
  end
end
