reload_settings = lambda {
  begin
    config = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
    SiteSetting.refresh!
  rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError
    # This will happen when migrating a new database
  end
}

if Rails.configuration.cache_classes
  reload_settings.call
else
  ActionDispatch::Reloader.to_prepare do
    reload_settings.call
  end
end
