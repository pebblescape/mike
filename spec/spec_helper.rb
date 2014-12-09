if ENV['CI']
  require 'simplecov'
  require 'simplecov-rcov'

  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end

  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails'
end

require 'rubygems'

require 'fabrication'
require 'certified'
require 'fakeweb'
FakeWeb.allow_net_connect = false

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.fail_fast = ENV['RSPEC_FAIL_FAST'] == "1"
  config.include Helpers
  config.mock_framework = :rspec
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
    # Sidekiq.error_handlers.clear

    Mike.current_user_provider = TestCurrentUserProvider
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

if defined?(Spring)
  Spring.after_fork do
    # This code will be run each time you run your specs.
    Mike.after_fork
  end
end
