require 'bootstrapper'

namespace :bootstrap do
  task boot: :environment do
    Bootstrapper.bootstrap
  end

  task database: :environment do
    Bootstrapper.database
  end
end
