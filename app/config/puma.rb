APP_ROOT = File.expand_path(File.expand_path(File.dirname(__FILE__)) + "/../")
num_workers = ENV["NUM_WEBS"].to_i > 0 ? ENV["NUM_WEBS"].to_i : 4

workers "#{num_workers}"
threads 8,32

pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
preload_app!

on_worker_boot do
  $redis.client.reconnect
end
