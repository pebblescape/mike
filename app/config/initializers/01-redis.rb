require "#{Rails.root}/lib/rails_redis"
$redis = RailsRedis.new

if defined?(Spring)
  Spring.after_fork do
    $redis = RailsRedis.new
    Mike::Application.config.cache_store.reconnect
  end
end