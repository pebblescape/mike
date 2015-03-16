source 'https://rubygems.org'
ruby '2.2.0'

gem 'rails', '4.2.0'
gem 'pg'
gem 'hiredis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'redis-rails'
gem 'sidekiq'
gem 'sinatra', require: nil

# BACKEND
gem 'sentry-raven'
gem 'skylight'
gem 'active_model_serializers'
gem 'oj'
gem 'rack-cors', require: false
gem 'versionist'
gem 'ci_reporter_rspec'
gem 'fast_xor'
gem 'lru_redux'
gem 'docker-api'
gem 'highline'
gem 'etcd'
gem 'gitlab-grack', github: 'pebblescape/grack', require: 'grack'
gem 'message_bus'

gem 'test'

group :test, :development do
  # dev helpers
  gem 'pry-rails'
  gem 'pry-nav'

  # rspec
  gem 'rspec-rails'
  gem 'shoulda', require: false
  gem 'rspec-given'
  gem 'rspec-legacy_formatters'

  # test assisters
  gem 'mock_redis'
  gem 'timecop'
  gem 'fabrication', require: false
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'certified', require: false

  # test backend
  gem 'rb-fsevent', require: RUBY_PLATFORM =~ /darwin/i ? 'rb-fsevent' : false
  gem 'rb-inotify', '~> 0.9', require: RUBY_PLATFORM =~ /linux/i ? 'rb-inotify' : false
  gem 'listen', '0.7.3', require: false

  # spring
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'webmock', require: false
  gem 'vcr', require: false
  gem 'minitest', require: false
end

group :development do
  gem 'binding_of_caller'
  gem 'better_errors'

  gem 'annotate'

  gem 'guard'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
end

group :production do
  gem 'rails_12factor'
end

gem 'puma', require: false
