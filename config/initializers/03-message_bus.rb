# MessageBus.extra_response_headers_lookup do |env|
#   {
#     "Access-Control-Allow-Origin" => Discourse.base_url,
#     "Access-Control-Allow-Methods" => "GET, POST",
#     "Access-Control-Allow-Headers" => "X-SILENCE-LOGGER, X-Shared-Session-Key"
#   }
# end

MessageBus.user_id_lookup do |env|
  user = CurrentUser.lookup_from_env(env)
  user.id if user
end

# Point at our redis
MessageBus.redis_config = YAML.load(ERB.new(File.new("#{Rails.root}/config/redis.yml").read).result)[Rails.env].symbolize_keys

MessageBus.long_polling_enabled = true
MessageBus.long_polling_interval = 25000

MessageBus.is_admin_lookup do |env|
  user = CurrentUser.lookup_from_env(env)
  if user && user.admin
    true
  else
    false
  end
end

MessageBus.cache_assets = !Rails.env.development?
MessageBus.enable_diagnostics
