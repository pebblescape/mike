class Release < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :build

  has_many :dynos

  validates_presence_of :description

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

  def deploy!
    app.dynos.destroy_all
    app.current_release = self

    app.formation.each do |type, count|
      count.times do |i|
        proc = self.dynos.create(type: type, number: i)
      end
    end
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
#  config_vars :hstore           default({})
#
# Indexes
#
#  index_releases_on_app_id    (app_id)
#  index_releases_on_build_id  (build_id)
#  index_releases_on_user_id   (user_id)
#
