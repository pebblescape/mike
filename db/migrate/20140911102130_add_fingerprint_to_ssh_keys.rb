class AddFingerprintToSshKeys < ActiveRecord::Migration
  def change
    add_column :ssh_keys, :fingerprint, :string, null: false
    add_index :ssh_keys, :fingerprint
  end
end
