require 'highline/import'
require 'shell_helpers'
require 'socket'

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
          "RestartPolicy": { "Name": "always", "MaximumRetryCount": 10 }
        }
      }

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
    adminkey = ENV['ADMIN_KEY'] || ask("Paste your public key in: ") { |q| q.echo = false }

    dbpass = ENV['DBPASS'] || ask('Database password: ') { |q| q.echo = 'x' }

    pubip = ENV['HOSTIP'] || ask('Host IP: ')
    port = ENV['PORT'] || ask('Mike port: ')
    sshport = ENV['SSHPORT'] || ask('Git port: ')
    sshkey = ENV['SSHHOSTKEY'] || ask('SSH host key path: ')
    mikekey = ENV['MIKE_AUTH_KEY'] || ask('Mike master key: ')

    raven = ENV['RAVEN_DSN'] || ask('Sentry key: ')
    skylight = ENV['SKYLIGHT_AUTHENTICATION'] || ask('Skylight key: ')

    dbname = 'mike'

    preload_image('pebbles/pebblerunner')
    preload_image('pebbles/mike')
    preload_image('pebbles/receiver')
    preload_image('redis')
    preload_image('postgres')
    preload_image('busybox')
    preload_image('quay.io/coreos/etcd:v2.0.0')

    existing = Docker::Container.all(all: true)
    bootstrap = existing.select { |c| c.info["Names"] && c.info["Names"].include?("/mike") }.empty?

    make_container('busybox', 'mike-etcd-volume', volumes: {"/default.etcd" => nil}).start
    make_container('busybox', 'mike-receiver-volume', volumes: {
      "/tmp/pebble-repos" => nil,
      "/tmp/pebble-cache" => nil
    }).start

    make_container('redis', 'mike-redis').start
    make_container('postgres', 'mike-postgres', env: [
      "POSTGRES_PASSWORD=#{dbpass}",
      "POSTGRES_USER=#{dbname}"
    ]).start

    make_container('quay.io/coreos/etcd:v2.0.0', 'mike-etcd', volumes_from: ["mike-etcd-volume"],
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
      volumes: {'/var/run/docker.sock' => '/var/run/docker.sock'},
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

    make_container('pebbles/receiver', 'mike-receiver', ports: {"#{sshport}" => '22'},
      volumes: {
        '/var/run/docker.sock' => '/var/run/docker.sock',
        sshkey => '/ssh_host_rsa_key'
      }, volumes_from: ['mike-receiver-volume'],
      env: ["MIKE_AUTH_KEY=#{mikekey}"],
      links: {"mike" => nil}).start

    if bootstrap
      topic "Running migrations"
      migrator = make_container('pebbles/mike', nil,
        mike_opts.merge(cmd: ["run", "bundle", "exec", "rake", "db:migrate"]))
      migrator.tap(&:start).attach(tty: true).each do |line|
        Kernel.puts(line[0]) if line[0]
      end
      migrator.delete(force: true)

      topic "Bootstrapping database"
      opts = mike_opts.merge(cmd: ["run", "bundle", "exec", "rake", "bootstrap:database"])
      opts[:env].concat([
        "MIKE_AUTH_KEY=#{mikekey}",
        "ADMIN_NAME=#{adminname}",
        "ADMIN_EMAIL=#{adminemail}",
        "ADMIN_PASS=#{adminpassword}",
        "ADMIN_KEY=#{adminkey}"
      ]).flatten.compact

      bootstrapper = make_container('pebbles/mike', nil, opts)
      bootstrapper.tap(&:start).attach(tty: true).each do |line|
        Kernel.puts(line[0]) if line[0]
      end
      bootstrapper.delete(force: true)
    end
  end

  task database: :environment do
    title "Creating system user"
    masterkey = ENV['MIKE_AUTH_KEY'] || ask("Master API key: ")  { |q| q.echo = 'x' }
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

    title "Adding SSH key"
    key = ENV['ADMIN_KEY'] || ask("Paste your public key in: ") { |q| q.echo = false }
    sshkey = SshKey.create!(user: user, key: key)
    say "<%= color('#{sshkey.fingerprint}', :yellow) %>"

    title "Generating admin API key"
    apikey = user.generate_api_key(Mike.system_user)
    say "<%= color('#{apikey.key}', :yellow) %>"
  end
end
