# TODO: delete containers etc when deleting
class App < ActiveRecord::Base
  belongs_to :owner, class_name: User

  has_many :builds, dependent: :destroy
  has_many :releases, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  serialize :config_vars
end

# == Schema Information
#
# Table name: apps
#
#  id          :uuid             not null, primary key
#  owner_id    :uuid
#  name        :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  config_vars :text
#
# Indexes
#
#  index_apps_on_name      (name)
#  index_apps_on_owner_id  (owner_id)
#
