class RailsRedis
  def self.raw_connection(config = nil)
    config ||= self.config
    redis_opts = {host: config['host'], port: config['port'], db: config['db']}
    redis_opts[:password] = config['password'] if config['password']
    Redis.new(redis_opts)
  end

  def self.config
    conffile = "#{Rails.root}/config/redis.yml"
    @config ||= YAML.load(ERB.new(File.new(conffile).read).result)[Rails.env]

    unless @config
      puts '', "Redis config for environment '#{Rails.env}' was not found in #{conffile}."
      raise 'Redis config not found'
    end

    @config
  end

  def self.url(config)
    pass = config['password'] ? ":#{config['password']}@" : ""
    "redis://#{pass}#{config['host']}:#{config['port']}/#{config['db']}"
  end

  def self.new_redis_store
    redis_store = ActiveSupport::Cache::RedisStore.new(self.url(self.config))
    redis_store
  end
end
