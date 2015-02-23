require 'highline/import'
require 'socket'
require 'securerandom'
require 'shell_helpers'

namespace :bootstrap do
  include ShellHelpers

  def title(msg)
    say "<%= color('#{msg}', :green) %>"
  end

  def preload_image(name)
    unless Docker::Image.exist?(name)
      title "Preloading #{name}"
      pipe!("docker pull #{name}")
    end
  end

  def make_container(image, name, options={})
    existing = Docker::Container.all(all: true)
    cnt = existing.select { |c| c.info["Names"] && c.info["Names"].include?("/#{name}") }.first
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

  task boot: :environment do
    adminname = ENV['ADMIN_NAME'] || ask("Admin name: ")
    adminemail = ENV['ADMIN_EMAIL'] || ask("Admin email: ")
    adminpassword = ENV['ADMIN_PASS'] || ask("Admin password: ")  { |q| q.echo = 'x' }

    dbpass = ENV['DBPASS'] || ask('Database password: ') { |q| q.echo = 'x' }

    pubip = ENV['HOSTIP'] || ask('Host IP: ')
    port = ENV['PORT'] || ask('Mike port: ')

    raven = ENV['RAVEN_DSN'] || ask('Sentry key: ')
    skylight = ENV['SKYLIGHT_AUTHENTICATION'] || ask('Skylight key: ')

    dbname = 'mike'

    preload_image('pebbles/pebblerunner')
    preload_image('pebbles/mike')
    preload_image('redis')
    preload_image('postgres')
    preload_image('busybox')
    preload_image('quay.io/coreos/etcd:v2.0.0')

    existing = Docker::Container.all(all: true)
    bootstrap = existing.select { |c| c.info["Names"] && c.info["Names"].include?("/mike") }.empty?

    make_container('busybox', 'mike-etcd-volume', volumes: {"/default.etcd" => nil}).start
    make_container('busybox', 'mike-volume', volumes: {
      "/tmp/pebble-repos" => nil,
      "/tmp/pebble-cache" => nil
    }).start

    make_container('redis', 'mike-redis', restart: true).start
    make_container('postgres', 'mike-postgres', restart: true, env: [
      "POSTGRES_PASSWORD=#{dbpass}",
      "POSTGRES_USER=#{dbname}"
    ]).start

    make_container('quay.io/coreos/etcd:v2.0.0', 'mike-etcd', restart: true, volumes_from: ["mike-etcd-volume"],
      cmd: [
        "-peer-addr", "#{pubip}:7001",
        "-addr", "#{pubip}:4001",
        "-bind-addr", "0.0.0.0:4001",
        "-initial-cluster", "default=http://#{pubip}:7001"
      ], ports: {
        '4001': '4001',
        '7001': '7001'
      }).start

    mike_opts = {
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
        "ETCD_HOST=etcd",
        "RAVEN_DSN=#{raven}",
        "SKYLIGHT_AUTHENTICATION=#{skylight}"
      ], links: {
        "mike-postgres" => "db",
        "mike-redis" => "redis",
        "mike-etcd" => "etcd"
      }
    }

    make_container('pebbles/mike', 'mike', mike_opts.merge(cmd: ["start", "web"], ports: {"#{port}" => '5000'})).start
    make_container('pebbles/mike', 'mike-worker', mike_opts.merge(cmd: ["start", "worker"])).start

    if bootstrap
      topic "Loading schema"
      migrator = make_container('pebbles/mike', nil,
        mike_opts.merge(cmd: ["run", "bundle", "exec", "rake", "db:schema:load"], restart: false))
      migrator.tap(&:start).attach { |stream, chunk| Kernel.puts chunk }
      migrator.delete(force: true)

      topic "Bootstrapping database"
      opts = mike_opts.merge(cmd: ["run", "bundle", "exec", "rake", "bootstrap:database"], restart: false)
      opts[:env].concat([
        "ADMIN_NAME=#{adminname}",
        "ADMIN_EMAIL=#{adminemail}",
        "ADMIN_PASS=#{adminpassword}"
      ]).flatten.compact

      bootstrapper = make_container('pebbles/mike', nil, opts)
      bootstrapper.tap(&:start).attach { |stream, chunk| Kernel.puts chunk }
      bootstrapper.delete(force: true)
    end
  end

  task database: :environment do
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
end
