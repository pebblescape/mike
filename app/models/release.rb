class Release < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :build
  belongs_to :user

  has_many :dynos

  validates_presence_of :description

  before_create :set_version

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

  def self.from_config(message, app, user)
    attrs = {
      app: app,
      user: user,
      build: app.current_release.try(:build),
      config_vars: app.config_vars,
      description: message
    }
    create!(attrs)
  end

  def rollback!
    newrelease = Release.create!({
      app: app,
      user: user,
      build: build,
      config_vars: config_vars,
      description: "Rollback to v#{version}"
    })
    newrelease.deploy!
    newrelease
  end

  def deploy!
    return unless self.build

    # Schedule old dynos for deletion
    old = app.dynos.to_a
    DynoReaper.perform_in(1.minute, old.map(&:id))

    # Spin up new dynos
    app.formation.each do |type, count|
      count.to_i.times do |i|
        proc = self.dynos.create(app: app, proctype: type, number: i)
      end
    end

    # Stop routing to old dynos
    old.each do |dyno|
      Router.remove_dyno(dyno)
    end

    app.set_current_release(self)
    app.sync_router
  end

  private

  def set_version
    self.version = app.releases.length + 1
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
#  config_vars :hstore           default("")
#  version     :integer          default("1")
#
# Indexes
#
#  index_releases_on_app_id    (app_id)
#  index_releases_on_build_id  (build_id)
#  index_releases_on_user_id   (user_id)
#
