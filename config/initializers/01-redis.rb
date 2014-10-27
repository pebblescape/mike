require "#{Rails.root}/lib/rails_redis"
$redis = RailsRedis.raw_connection

if defined?(Spring)
  Spring.after_fork do
    $redis = RailsRedis.raw_connection
    Mike::Application.config.cache_store.reconnect
  end
end