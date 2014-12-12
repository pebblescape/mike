class Release < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :build
  belongs_to :user

  validates_presence_of :description

  serialize :config_vars

  def self.from_push(build, app, user)
    attrs = {
      app: app,
      user: user,
      build: build,
      config_vars: app.config_vars,
      description: "Deployed #{build.short_commit}"
    }
    create!(attrs)
  end

  def version
    app.releases.index(self) + 1
  end
end

# == Schema Information
#
# Table name: releases
#
#  id          :uuid             not null, primary key
#  user_id     :uuid
#  app_id      :uuid
#  build_id    :uuid
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
