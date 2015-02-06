web: bundle exec puma -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq -e $RAILS_ENV
boot: bundle exec rake bootstrap:boot
