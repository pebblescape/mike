require_dependency 'git_repo'
require_dependency 'upgrader'
require_dependency 'dashboard_index'

class V1::AdminController < ApiController
  def upgrades
    repo = GitRepo.new(Rails.root.to_s, 'mike')

    upgrades = [
      {
        id: 'mike',
        name: 'mike',
        path: Rails.root.to_s,
        version: repo.latest_local_commit,
        upgrading: repo.upgrading?,
        url: 'https://github.com/pebblescape/mike'
      }, {
        id: 'dashboard',
        name: 'dashboard',
        version: DashboardIndex.current_version,
        url: 'https://github.com/pebblescape/dashboard'
      }
    ]

    render json: {upgrades: upgrades}
  end

  def progress
    repo = GitRepo.new(params[:path])
    upgrader = Upgrader.new(current_user.id, repo, params[:version])
    render json: {progress: {logs: upgrader.find_logs, percentage: upgrader.last_percentage } }
  end

  def latest
    case params[:name]
    when 'mike'
      repo = GitRepo.new(Rails.root.to_s, 'mike')
      repo.update! if Rails.env == 'production'
      result = {version: repo.latest_origin_commit,
                commits_behind: repo.commits_behind,
                date: repo.latest_origin_commit_date }
    when 'dashboard'
      result = {version: DashboardIndex.latest_version}
    end

    render json: {latest: result }
  end

  def upgrade
    case params[:name]
    when 'mike'
      repo = GitRepo.new(params[:path], params[:name])
      Thread.new do
        upgrader = Upgrader.new(current_user.id, repo, params[:version])
        upgrader.upgrade
      end
    when 'dashboard'
      DashboardIndex.cache_latest('master')
    end

    render text: "OK"
  end

  def reset_upgrade
    repo = GitRepo.new(params[:path])
    upgrader = Upgrader.new(current_user.id, repo, params[:version])
    upgrader.reset!
    render text: "OK"
  end

  def ps
    if RUBY_PLATFORM =~ /darwin/
      ps_output = `ps aux -m`
    else
      ps_output = `ps auxf --sort -rss`
    end
    render text: ps_output
  end
end
