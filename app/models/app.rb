class App < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :owner, class_name: User

  belongs_to :current_release, class_name: Release

  has_many :builds, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :dynos, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  before_save :check_reserved
  before_create :set_formation

  def self.find_by_uuid_or_name(query)
    if query.length == 36
      App.find(query)
    else
      App.find_by_name(query)
    end
  end

  # TODO: configurable root host
  def hostname
    "#{name}.pebblesinspace.com"
  end

  def sync_router
    Router.sync_app(self)
  end

  def set_current_release(release)
    update_attribute(:current_release_id, release.id)
  end

  private

  # Mike reserves the api and git subdomains
  def check_reserved
    !%w(api git).include?(name)
  end

  def set_formation
    unless self.formation
      self.formation = { web: 1 }
    end
  end
end

# == Schema Information
#
# Table name: apps
#
#  id                 :uuid             not null, primary key
#  owner_id           :uuid
#  name               :string(255)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  config_vars        :hstore           default("")
#  formation          :hstore           default("\"web\"=>\"1\"")
#  current_release_id :uuid
#
# Indexes
#
#  index_apps_on_name      (name)
#  index_apps_on_owner_id  (owner_id)
#
