class Release < ActiveRecord::Base
  belongs_to :app
  belongs_to :build
  belongs_to :user

  validates_presence_of :description
  validates_presence_of :version

  serialize :config_vars
end

# == Schema Information
#
# Table name: releases
#
#  id          :uuid             not null, primary key
#  user_id     :uuid
#  app_id      :uuid
#  build_id    :uuid
#  version     :integer          not null
#  description :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  config_vars :text
#
# Indexes
#
#  index_releases_on_app_id    (app_id)
#  index_releases_on_build_id  (build_id)
#  index_releases_on_user_id   (user_id)
#
