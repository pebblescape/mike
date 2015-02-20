class DropSshKeys < ActiveRecord::Migration
  def change
    drop_table :ssh_keys
  end
end
