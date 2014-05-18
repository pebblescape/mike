sidekiq_redis = { url: $redis.url, namespace: 'mikesidekiq' }

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis
end

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis
end

if Sidekiq.server?
  Rails.application.config.after_initialize do
    require 'scheduler/scheduler'
    manager = Scheduler::Manager.new
    Scheduler::Manager.discover_schedules.each do |schedule|
      manager.ensure_schedule!(schedule)
    end
    Thread.new do
      while true
        begin
          manager.tick
        rescue => e
          # the show must go on
          Mike.handle_exception(e)
        end
        sleep 1
      end
    end
  end
end

Sidekiq.logger.level = Logger::WARN
