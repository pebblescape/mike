if ENV['CI']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'rubygems'
require 'rbtrace'

require 'fakeweb'
FakeWeb.allow_net_connect = false

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
require 'fabrication'
require 'mocha/api'
require 'fakeweb'
require 'certified'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'shoulda'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# let's not run seed_fu every test
# SeedFu.quiet = true if SeedFu.respond_to? :quiet
# SeedFu.seed

RSpec.configure do |config|
  config.fail_fast = ENV['RSPEC_FAIL_FAST'] == "1"
  config.include Helpers
  config.include MessageBus
  config.mock_framework = :mocha
  config.order = 'random'

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  config.before(:suite) do
    Mike.current_user_provider = TestCurrentUserProvider

    SiteSetting.refresh!

    # Rebase defaults
    #
    # We nuke the DB storage provider from site settings, so need to yank out the existing settings
    #  and pretend they are default.
    # There are a bunch of settings that are seeded, they must be loaded as defaults
    SiteSetting.current.each do |k,v|
      SiteSetting.defaults[k] = v
    end

    require_dependency 'site_settings/local_process_provider'
    SiteSetting.provider = SiteSettings::LocalProcessProvider.new
  end

  config.before :each do |x|
    # disable all observers, enable as needed during specs
    # ActiveRecord::Base.observers.disable :all
    SiteSetting.provider.all.each do |setting|
      SiteSetting.remove_override!(setting.name)
    end
  end

  class TestCurrentUserProvider < Auth::DefaultCurrentUserProvider
    def log_on_user(user,session,cookies)
      session[:current_user_id] = user.id
      super
    end

    def log_off_user(session,cookies)
      session[:current_user_id] = nil
      super
    end
  end
end

def freeze_time(now=Time.now)
  DateTime.stubs(:now).returns(DateTime.parse(now.to_s))
  Time.stubs(:now).returns(Time.parse(now.to_s))
end

Spring.after_fork do
  # This code will be run each time you run your specs.
  Mike.after_fork
end
