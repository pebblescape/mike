source 'https://rubygems.org'
ruby '2.1.4'

gem 'rails', '4.1.8'
gem 'pg'
gem 'hiredis'
gem 'redis', require: ['redis', 'redis/connection/hiredis']
gem 'redis-rails'
gem 'sidekiq'
gem 'sinatra', require: nil

# # ASSETS
gem 'sass-rails', '~> 4.0.5'
gem 'less-rails'
gem 'uglifier'
gem 'therubyracer', require: 'v8'
gem 'jquery-rails'
gem 'ember-rails'
gem 'ember-source'
gem 'handlebars-source'
gem 'barber'
gem 'slim'

# BACKEND
# gem 'sentry-raven'
# gem "skylight"
gem 'active_model_serializers'
gem 'oj'
gem 'rack-cors', require: false
gem 'versionist'
gem 'ci_reporter_rspec'
gem 'fast_xor'
gem 'lru_redux'
gem 'docker-api'
gem 'highline'


# DEV & TEST
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

# TEST
group :test do
  gem 'fakeweb', require: false
  gem 'minitest', require: false
end

# DEV
group :development do
  gem 'web-console', '~> 2.0'
  gem 'annotate'

  gem 'guard'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
end

group :production do
  gem 'rails_12factor'
end

gem 'rack-mini-profiler', require: false
gem 'stackprof', require: false
gem 'flamegraph', require: false
gem 'memory_profiler', require: false

# SERVERS
gem 'thin', require: false
gem 'puma', require: false
gem 'unicorn', require: false
