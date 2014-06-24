module Mike  
  def self.git_version
    return $git_version if $git_version

    begin
      $git_version ||= ENV['GIT_REV'] || `git rev-parse HEAD`.strip
    rescue
      $git_version = "unknown"
    end
  end
  
  def self.after_fork
    $redis.client.reconnect
    Rails.cache.reconnect
    # # /!\ HACK /!\ force sidekiq to create a new connection to redis
    # Sidekiq.instance_variable_set(:@redis, nil)
  end
end