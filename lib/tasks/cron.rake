namespace :cron do
  task test: :environment do
    EmptyWorker.perform_in(2.minutes, 1)
  end
end
