require 'open3'

class Upgrader
  def initialize(user_id, repo, from_version)
    @user_id = user_id
    @repo = repo
    @from_version = from_version
  end

  def reset!
    @repo.stop_upgrading
    clear_logs
    percent(0)
  end

  def upgrade
    return unless @repo.start_upgrading

    percent(0)
    clear_logs

    # HEAD@{upstream} is just a fancy way how to say origin/master (in normal case)
    # see http://stackoverflow.com/a/12699604/84283
    run("cd #{@repo.path} && git fetch && git reset --hard HEAD@{upstream}")
    log("********************************************************")
    log("*** Please be patient, next steps might take a while ***")
    log("********************************************************")
    percent(5)

    run("/scripts/run run env")
    run("/scripts/run run bundle install --deployment --without test --without development")
    percent(25)

    run("/scripts/run run bundle exec rake db:migrate")
    percent(50)

    log("***  Bundling assets. This might take a while *** ")
    run("/scripts/run run bundle exec rake assets:precompile")
    percent(75)

    sidekiq_pid = `ps aux | grep sidekiq.*busy | grep -v grep | awk '{ print $2 }'`.strip.to_i
    if sidekiq_pid > 0
      Process.kill("TERM", sidekiq_pid)
      log("Killed sidekiq")
    else
      log("Warning: Sidekiq was not found")
    end
    percent(100)

    publish('status', 'complete')
    pidpath = Rails.root.join("tmp/puma.pid")
    if File.exist?(pidpath)
      pid = File.read(pidpath)
      log("***********************************************")
      log("*** After restart, upgrade will be complete ***")
      log("***********************************************")
      log("Restarting puma pid: #{pid}")
      Process.kill("USR2", pid.to_i)
      log("DONE")
    else
      log("Did not find puma master")
    end
  rescue => ex
    publish('status', 'failed')
    STDERR.puts("FAILED TO UPGRADE")
    STDERR.puts(ex.inspect)
    raise
  ensure
    @repo.stop_upgrading
  end

  def publish(type, value)
    # MessageBus.publish("/docker/upgrade", {type: type, value: value}, user_ids: [@user_id])
  end

  def run(cmd)
    log "$ #{cmd}"
    msg = ""
    clear_env = Hash[*ENV.map{|k,v| [k,nil]}
                     .reject{ |k,v|
                       ["PWD","HOME","SHELL","PATH"].include?(k)
                     }
                     .flatten]
    clear_env["RAILS_ENV"] = "production"
    clear_env["TERM"] = 'dumb' # claim we have a terminal

    retval = nil
    Open3.popen2e(clear_env, "cd #{Rails.root} && #{cmd} 2>&1") do |_in, out, wait_thread|
      out.each do |line|
        line.rstrip! # the client adds newlines, so remove the one we're given
        log(line)
        msg << line << "\n"
      end
      retval = wait_thread.value
    end

    unless retval == 0
      STDERR.puts("FAILED: '#{cmd}' exited with a return value of #{retval}")
      STDERR.puts(msg)
      raise RuntimeError
    end
  end

  def logs_key
    "logs:#{@repo.path}:#{@from_version}"
  end

  def clear_logs
    $redis.del(logs_key)
  end

  def find_logs
    $redis.get(logs_key)
  end

  def percent_key
    "percent:#{@repo.path}:#{@from_version}"
  end

  def last_percentage
    $redis.get(percent_key)
  end

  def percent(val)
    $redis.set(percent_key, val)
    $redis.expire(percent_key, 30.minutes)
    publish('percent', val)
  end

  def log(message)
    $redis.append logs_key, message + "\n"
    $redis.expire(logs_key, 30.minutes)
    publish 'log', message
  end
end
