if ENV["RAILS_ENV"] == "test" || ENV["RAILS_ENV"] == "development"
  require 'rubygems'
  require 'ci/reporter/rake/rspec'

  namespace :ci do
    task :all => ['ci:setup:rspec', 'spec']
  end
end