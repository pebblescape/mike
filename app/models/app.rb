# TODO: delete containers etc when deleting
class App < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :owner, class_name: User

  has_many :builds, dependent: :destroy
  has_many :releases, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  serialize :config_vars
  serialize :formation

  before_create :set_formation

  def self.find_by_uuid_or_name(query)
    if query.length == 36
      App.find(query)
    else
      App.find_by_name(query)
    end
  end

  def set_formation
    unless self.formation
      self.formation = {web: 1}
    end
  end
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
#  formation   :text
#
# Indexes
#
#  index_apps_on_name      (name)
#  index_apps_on_owner_id  (owner_id)
#
