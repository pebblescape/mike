require_dependency 'enum'

# TODO: delete images etc when deleting
class Build < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :user

  has_many :releases

  validates_presence_of :status
  # validates_presence_of :process_types
  # validates_presence_of :size

  before_destroy do
    begin
      remove
    rescue
      Docker::Error::NotFoundError
    end
  end

  def self.status_types
    @status_types ||= Enum.new(:pending, :failed, :succeeded)
  end

  def self.from_push(params, cid, app, user)
    container = Docker::Container.get(cid)
    unless container.info["State"]["ExitCode"] == 0
      raise Mike::BuildError, "Build failed in container #{cid}"
    end

    defaults = {
      status: status_types[:pending],
      app: app,
      user: user
    }

    create!(params.merge(defaults)).tap do |build|
      image = container.commit
      image.tag(repo: "pebble/#{app.name}", tag: build.id)
      image.tag(repo: "pebble/#{app.name}")
      container.remove

      infocnt = Docker::Container.create('Cmd' => ['info'], 'Image' => image.id)
      info = infocnt.tap(&:start).attach
      infocnt.remove

      parsed = JSON.parse(info[0][0])
      build.process_types = parsed['process_types'].inject(&:merge)
      build.size = parsed['app_size']
      build.buildpack_description = parsed['buildpack_name']
      build.status = status_types[:succeeded]
      build.image_id = image.id
      build.save
    end
  end

  def image
    Docker::Image.get(self.image_id)
  end

  def short_commit
    commit[0..6]
  end

  def remove
    image.remove(force: true)
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
#  process_types         :hstore           default({})
#  size                  :integer
#  created_at            :datetime
#  updated_at            :datetime
#  image_id              :string(255)
#
# Indexes
#
#  index_builds_on_app_id   (app_id)
#  index_builds_on_user_id  (user_id)
#
