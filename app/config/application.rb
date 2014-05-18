require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mike
  class Application < Rails::Application
    require 'mike'
    
    config.autoload_paths += Dir["#{config.root}/app/serializers"]
    config.autoload_paths += Dir["#{config.root}/lib/validators/"]
    config.autoload_paths += Dir["#{config.root}/app"]
    
    config.assets.precompile += %w( vendor.js preloader.js )
    
    Dir.glob("#{config.root}/app/assets/javascripts/locales/*.js.erb").each do |file|
      config.assets.precompile << "locales/#{file.match(/([a-z_A-Z]+\.js)\.erb$/)[1]}"
    end
    
    config.handlebars.templates_root = 'mike/templates'
    config.ember.variant = :development

    # route all exceptions via our router
    config.exceptions_app = self.routes
    
    require 'rails_redis'    
    # Use redis for our cache
    config.cache_store = RailsRedis.new_redis_store

    # http cache upstream
    config.action_dispatch.rack_cache = nil

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    # We need to be able to spin threads
    config.active_record.thread_safe!
    
    config.active_record.schema_format = :sql
    
    # per https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet
    config.pbkdf2_iterations = 64000
    config.pbkdf2_algorithm = "sha256"
    
    config.generators do |g|
      g.test_framework :rspec
    end
    
    require 'auth'
  end
end
