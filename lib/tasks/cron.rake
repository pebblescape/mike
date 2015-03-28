namespace :cron do
  task minute: :environment do
    # EmptyWorker.perform_in(2.minutes, 1)
  end

  task tenminutes: :environment do
    # EmptyWorker.perform_in(2.minutes, 1)
  end

  task hour: :environment do
    # EmptyWorker.perform_in(2.minutes, 1)
  end

  task day: :environment do
    # EmptyWorker.perform_in(2.minutes, 1)
  end
end
