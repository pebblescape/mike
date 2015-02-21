class Dyno < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :release

  before_create do |dyno|
    dyno.started_at = Time.now
  end

  before_create do |dyno|
    dyno.port = 5000
    dyno.spawn

    return unless dyno.proctype == "web"
    Router.add_dyno(self)
  end

  before_destroy do |dyno|
    return unless dyno.proctype == "web"
    Router.remove_dyno(self)
    true
  end

  before_destroy do
    begin
      stop && remove
    rescue
      Docker::Error::NotFoundError
    end
  end

  def name
    "#{proctype}.#{number}"
  end

  def uptime
    started_at ? Time.now - started_at : 0
  end

  def url
    "http://#{server}"
  end

  def server
    "#{ip_address}:#{port}"
  end

  def spawn
    config = {
      "DATABASE_URL" => "sqlite3:///app/db/test.sqlite"
    }.merge(release.config_vars).map { |k,v| "#{k}=#{v}" }

    container = Docker::Container.create(
      'Image' => release.build.image_id,
      'Cmd'   => ["start", proctype],
      'Env'   => config.concat(["PORT=#{port}"]),
      'HostConfig' => {
        'RestartPolicy' => { "Name": "always", "MaximumRetryCount": 10 }
      }
    ).start

    self.container_id = container.id
    self.ip_address = container.json["NetworkSettings"]["IPAddress"]

    save! if !new_record?
  end

  def kill
    clear_started_at
    container.kill
  end

  def start
    container.start
    reset_started_at
  end

  def stop
    clear_started_at
    container.stop
  end

  def restart
    container.restart
    reset_started_at
  end

  def remove
    clear_started_at
    container.delete
  end

  private

  def reset_started_at
    update(started_at: Time.now)
  end

  def clear_started_at
    update(started_at: nil)
  end

  def container
    Docker::Container.get(container_id)
  end

end

# == Schema Information
#
# Table name: dynos
#
#  id           :uuid             not null, primary key
#  app_id       :uuid
#  release_id   :uuid
#  proctype     :string(255)      not null
#  port         :integer
#  number       :integer
#  container_id :string(255)
#  ip_address   :inet
#  started_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_dynos_on_app_id      (app_id)
#  index_dynos_on_release_id  (release_id)
#
