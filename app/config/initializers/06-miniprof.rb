if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.storage_instance = Rack::MiniProfiler::RedisStore.new(connection: RailsRedis.raw_connection)
  
  # without a user provider our results will use the ip address for namespacing
  #  with a load balancer in front this becomes really bad as some results can
  #  be stored associated with ip1 as the user and retrieved using ip2 causing 404s
  Rack::MiniProfiler.config.user_provider = lambda do |env|
    Rack::Request.new(env).ip
  end
  
  Rack::MiniProfiler.config.pre_authorize_cb = lambda do |env|
    (env['HTTP_USER_AGENT'] !~ /iPad|iPhone|Nexus 7|Android/) &&
    (env['PATH_INFO'] !~ /assets/) &&
    (env['PATH_INFO'] !~ /fonts/) &&
    (env['PATH_INFO'] !~ /teaspoon/) &&
    (env['PATH_INFO'] !~ /sidekiq/)
  end

  Rack::MiniProfiler.config.position = 'right'
  Rack::MiniProfiler.config.backtrace_ignores ||= []
  # Rack::MiniProfiler.config.backtrace_ignores << /config\/initializers\/quiet_logger/
end