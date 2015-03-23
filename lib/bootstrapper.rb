require 'highline/import'
require 'socket'
require 'securerandom'
require 'shell_helpers'

class Bootstrapper
  include ShellHelpers

  attr_reader :adminname, :adminemail, :adminpassword, :dbpass, :port, :redis_port, :raven, :skylight, :dbname

  def self.bootstrap; self.new.bootstrap; end
  def self.database; self.new.database; end

  def bootstrap
    set_opts

    refresh_image('pebbles/pebblerunner')
    refresh_image('pebbles/mike')
    refresh_image('redis')
    refresh_image('postgres')
    refresh_image('busybox')

    title "Removing existing"
    %w(mike mike-redis mike-postgres mike-data-volume mike-volume).each do |name|
      cnt = get_container(name)
      next unless cnt
      cnt.stop
      cnt.wait(10)
      cnt.delete(force: true)
    end

    make_container('busybox', 'mike-data-volume', volumes: {
      "/data" => nil,
      "/var/lib/postgresql/data" => nil
    }).start
    make_container('busybox', 'mike-volume', volumes: {
      "/tmp/pebble-repos" => nil,
      "/tmp/pebble-cache" => nil
    }).start

    make_container('redis', 'mike-redis', restart: true, volumes_from: ["mike-data-volume"],
      cmd: ['redis-server', '--appendonly', 'yes'], ports: {"#{redis_port}" => '6379'})).start
    make_container('postgres', 'mike-postgres', restart: true, volumes_from: ["mike-data-volume"],
      env: [
      "POSTGRES_PASSWORD=#{dbpass}",
      "POSTGRES_USER=#{dbname}"
    ]).start

    title "Loading schema"
    migrator = make_container('pebbles/mike', nil,
      mike_opts.merge(entrypoint: '/scripts/run', cmd: ["run", "bundle", "exec", "rake", "db:schema:load"], restart: false))
    migrator.tap(&:start).attach { |stream, chunk| Kernel.puts chunk }
    migrator.delete(force: true)

    title "Bootstrapping database"
    opts = mike_opts.merge(entrypoint: '/scripts/run', cmd: ["run", "bundle", "exec", "rake", "bootstrap:database"], restart: false)
    opts[:env].concat([
      "ADMIN_NAME=#{adminname}",
      "ADMIN_EMAIL=#{adminemail}",
      "ADMIN_PASS=#{adminpassword}"
    ]).flatten.compact

    bootstrapper = make_container('pebbles/mike', nil, opts)
    bootstrapper.tap(&:start).attach { |stream, chunk| Kernel.puts chunk }
    bootstrapper.delete(force: true)

    make_container('pebbles/mike', 'mike', mike_opts.merge(ports: {"#{port}" => '5000'})).start
  end

  def database
    title "Creating system user"
    masterkey = ENV['MIKE_AUTH_KEY'] || SecureRandom.hex(32)
    unless Mike.system_user
      User.create!(id: Mike::SYSTEM_USER_ID, name: 'system', email: 'no_email', password: SecureRandom.hex, active: true, admin: true)
      title "Creating master API key"
      master_key = ApiKey.create_master_key(masterkey)
      say "<%= color('#{master_key.key}', :yellow) %>"
    end

    title "Setting up default admin"
    name = ENV['ADMIN_NAME'] || ask("Admin name: ")
    email = ENV['ADMIN_EMAIL'] || ask("Admin email: ")
    password = ENV['ADMIN_PASS'] || ask("Admin password: ")  { |q| q.echo = 'x' }

    user = User.create!(name: name, email: email, password: password, admin: true, active: true)
    title "Admin created"
    say "<%= color('#{user.inspect}', :yellow) %>"

    title "Generating admin API key"
    apikey = user.generate_api_key(Mike.system_user)
    say "<%= color('#{apikey.key}', :yellow) %>"
  end

  # DISPLAY HELPERS

  def title(msg)
    say "<%= color('#{msg}', :green) %>"
  end

  def fail(msg)
    say "<%= color('#{msg}', :red) %>"
  end

  # COMMON HELPERS

  def set_opts
    @adminname = ENV['ADMIN_NAME'] || ask("Admin name: ")
    @adminemail = ENV['ADMIN_EMAIL'] || ask("Admin email: ")
    @adminpassword = ENV['ADMIN_PASS'] || ask("Admin password: ")  { |q| q.echo = 'x' }
    @dbpass = ENV['DBPASS'] || ask('Database password: ') { |q| q.echo = 'x' }
    @port = ENV['PORT'] || ask('Mike port: ')
    @redis_port = ENV['REDIS_PORT'] || ask('Redis port: ')
    @raven = ENV['RAVEN_DSN'] || ask('Sentry key: ')
    @skylight = ENV['SKYLIGHT_AUTHENTICATION'] || ask('Skylight key: ')

    @dbname = 'mike'
  end

  def mike_opts
    {
      restart: true,
      volumes: {'/var/run/docker.sock' => '/var/run/docker.sock'},
      volumes_from: ['mike-volume'],
      env: [
        "PORT=5000",
        "DATABASE_URL=postgres://#{dbname}:#{dbpass}@db/#{dbname}",
        "REDIS_URL=redis://redis:6379",
        "DBPASS=#{dbpass}",
        "DBUSER=#{dbname}",
        "DBNAME=#{dbname}",
        "RAVEN_DSN=#{raven}",
        "SKYLIGHT_AUTHENTICATION=#{skylight}"
      ], links: {
        "mike-postgres" => "db",
        "mike-redis" => "redis"
      }
    }
  end

  # DOCKER HELPERS

  def refresh_image(name)
    title "Pulling #{name}"
    run!("docker pull #{name}")
    Docker::Image.get(name).id
  end

  def get_container(name)
    existing = Docker::Container.all(all: true)
    existing.select { |c| c.info["Names"] && c.info["Names"].include?("/#{name}") }.first
  end

  def make_container(image, name, options={})
    cnt = get_container(name)

    unless cnt
      title "Starting #{name}" if name
      apiopts = {
        'User' => '',
        'Cmd' => [],
        'Env' => [],
        'Volumes' => {},
        'ExposedPorts' => {},
        'HostConfig' => {
          'Binds' => [],
          'Links' => [],
          'VolumesFrom' => [],
          'PortBindings' => {},
          "RestartPolicy": {}
        }
      }

      if options.delete(:restart)
        apiopts['HostConfig']['RestartPolicy'] = { "Name": "always", "MaximumRetryCount": 10 }
      end

      apiopts['Cmd'] = options.delete(:cmd) || []
      apiopts['Entrypoint'] = options.delete(:entrypoint) || nil
      apiopts['User'] = options.delete(:user) || ''
      apiopts['HostConfig']['VolumesFrom'] = options.delete(:volumes_from) || []

      (options.delete(:volumes) || {}).each do |host, local|
        apiopts['Volumes'][local || host] = {}
        apiopts['HostConfig']['Binds'] << "#{host}:#{local}:rw" if local
      end

      (options.delete(:links) || {}).each do |name, link|
        apiopts['HostConfig']['Links'] << "#{name}:#{link || name}"
      end

      (options.delete(:env) || []).each do |env|
        apiopts['Env'] << env
      end

      (options.delete(:ports) || {}).each do |port, bind|
        if bind
          apiopts['ExposedPorts']["#{bind}/tcp"] = {}
          apiopts['HostConfig']['PortBindings']["#{bind}/tcp"] = [{"HostIp": "0.0.0.0", "HostPort": "#{port}"}]
        else
          apiopts['ExposedPorts']["#{port}/tcp"] = {}
        end
      end

      cnt = Docker::Container.create(apiopts.merge({'Image' => image, 'name' => name}))
    end

    return cnt
  end
end
