require_dependency 'auth/default_current_user_provider'

module Mike
  # When they try to do something they should be logged in for
  class NotLoggedIn < Exception; end
  
  # When they don't have permission to do something
  class InvalidAccess < Exception; end
  
  # When the input is somehow bad
  class InvalidParameters < Exception; end
  
  require 'sidekiq/exception_handler'
  class SidekiqExceptionHandler
    extend Sidekiq::ExceptionHandler
  end

  def self.handle_exception(ex, context=nil, parent_logger = nil)
    context ||= {}
    parent_logger ||= SidekiqExceptionHandler
    parent_logger.handle_exception(ex, context)
  end
  
  def self.git_version
    return $git_version if $git_version

    begin
      $git_version ||= ENV['GIT_REV'] || `git rev-parse HEAD`.strip
    rescue
      $git_version = "unknown"
    end
  end

  def self.assets_digest
    @assets_digest ||= begin
      digest = Digest::MD5.hexdigest(ActionView::Base.assets_manifest.assets.values.sort.join)

      channel = "/global/asset-version"
      message = MessageBus.last_message(channel)

      unless message && message.data == digest
        MessageBus.publish channel, digest
      end
      digest
    end
  end
  
  def self.enable_readonly_mode
    $redis.set readonly_mode_key, 1
    MessageBus.publish(readonly_channel, true)
    true
  end

  def self.disable_readonly_mode
    $redis.del readonly_mode_key
    MessageBus.publish(readonly_channel, false)
    true
  end

  def self.readonly_mode?
    !!$redis.get(readonly_mode_key)
  end
  
  def self.readonly_mode_key
    "readonly_mode"
  end

  def self.readonly_channel
    "/site/read-only"
  end
  
  def self.authenticators
    Users::OmniauthCallbacksController::BUILTIN_AUTH
  end
  
  def self.current_user_provider
    @current_user_provider || Auth::DefaultCurrentUserProvider
  end

  def self.current_user_provider=(val)
    @current_user_provider = val
  end
  
  def self.after_fork
    MessageBus.after_fork
    SiteSetting.after_fork
    $redis.client.reconnect
    Rails.cache.reconnect
    # # /!\ HACK /!\ force sidekiq to create a new connection to redis
    Sidekiq.instance_variable_set(:@redis, nil)
  end
end