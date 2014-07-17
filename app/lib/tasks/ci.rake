if ENV["RAILS_ENV"] == "test" || ENV["RAILS_ENV"] == "development"
  require 'rubygems'
  require 'rspec/core/rake_task'

  namespace :ci do
    def rspec_report_path
      "spec/reports"
    end

    task :spec_report_setup do
      rm_rf rspec_report_path
      mkdir_p rspec_report_path
    end
    
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.rspec_opts = "--format CI::Reporter::RSpec --color --tty --no-drb"
    end

    task :all => [:spec_report_setup,
                  :spec]
  end
end