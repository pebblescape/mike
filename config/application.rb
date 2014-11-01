require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'active_support/dependencies'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mike
  class Application < Rails::Application
    require 'mike'
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    config.autoload_paths += Dir["#{config.root}/app/serializers"]
    config.autoload_paths += Dir["#{config.root}/lib/validators/"]
    
    require 'rails_redis'    
    # Use redis for our cache
    config.cache_store = RailsRedis.new_redis_store
    $redis = RailsRedis.new

    # http cache upstream
    config.action_dispatch.rack_cache = nil
    
    config.active_record.thread_safe!    
    config.active_record.schema_format = :sql
    
    # per https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet
    config.pbkdf2_iterations = 64000
    config.pbkdf2_algorithm = "sha256"
    
    config.generators do |g|
      g.test_framework :rspec
    end
    
    # Our templates shouldn't start with 'mike/templates'
    config.handlebars.templates_root = 'mike/templates'
    
    # ember stuff only used for asset precompliation, production variant plays up
    config.ember.variant = :development
    config.ember.ember_location = "#{Rails.root}/vendor/assets/javascripts/production/ember.js"
    config.ember.handlebars_location = "#{Rails.root}/vendor/assets/javascripts/handlebars.js"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
