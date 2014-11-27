# TODO: delete containers etc when deleting
class App < ActiveRecord::Base
  belongs_to :owner, class_name: User
  
  has_many :builds

  validates_presence_of :name
  validates_uniqueness_of :name
end

# == Schema Information
#
# Table name: apps
#
#  id         :uuid             not null, primary key
#  owner_id   :uuid
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_apps_on_name  (name)
#
