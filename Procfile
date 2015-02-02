web: bundle exec puma -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq -e $RAILS_ENV
cron: bundle exec whenever -w && cron -f
boot: bundle exec rake bootstrap:boot
