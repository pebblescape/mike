require_dependency 'enum'

# TODO: delete images etc when deleting
class Build < ActiveRecord::Base
  belongs_to :app
  belongs_to :user

  has_many :releases

  validates_presence_of :status
  validates_presence_of :process_types
  validates_presence_of :size

  serialize :process_types

  def self.status_types
    @status_types ||= Enum.new(:pending, :failed, :succeeded)
  end
end

# == Schema Information
#
# Table name: builds
#
#  id                    :uuid             not null, primary key
#  user_id               :uuid
#  app_id                :uuid
#  status                :integer          not null
#  buildpack_description :string(255)
#  commit                :string(255)
#  process_types         :text             not null
#  size                  :integer          not null
#  created_at            :datetime
#  updated_at            :datetime
#
# Indexes
#
#  index_builds_on_app_id   (app_id)
#  index_builds_on_user_id  (user_id)
#
