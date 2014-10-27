require_dependency 'auth/default_current_user_provider'

module Mike
  # When they don't have permission to do something
  class InvalidAccess < Exception; end
  
  # When they try to do something they should be logged in for
  class NotLoggedIn < Exception; end
  
  SYSTEM_USER_ID = -1 unless defined? SYSTEM_USER_ID

  def self.system_user
    User.find_by(id: SYSTEM_USER_ID)
  end
  
  def self.git_version
    return $git_version if $git_version

    begin
      $git_version ||= ENV['GIT_REV'] || `git rev-parse HEAD`.strip
    rescue
      $git_version = "unknown"
    end
  end
  
  def self.current_user_provider
    @current_user_provider || Auth::DefaultCurrentUserProvider
  end

  def self.current_user_provider=(val)
    @current_user_provider = val
  end

  # all forking servers must call this
  # after fork, otherwise Discourse will be
  # in a bad state
  def self.after_fork
    # MessageBus.after_fork
    $redis.client.reconnect
    Rails.cache.reconnect
    # Logster.store.redis.reconnect
    # shuts down all connections in the pool
    Sidekiq.redis_pool.shutdown{|c| nil}
    # re-establish
    Sidekiq.redis = sidekiq_redis_config
    nil
  end

  def self.sidekiq_redis_config
    { url: $redis.url, namespace: 'sidekiq' }
  end
end