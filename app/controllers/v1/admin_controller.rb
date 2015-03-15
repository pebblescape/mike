require_dependency 'git_repo'
require_dependency 'upgrader'

class V1::AdminController < ApiController
  def repos
    repos = [
      GitRepo.new(Rails.root.to_s, 'mike'),
      GitRepo.new(Rails.root.join("public").to_s, 'dashboard')
    ]

    repos.map! do |r|
      result = {name: r.name, path: r.path, branch: r.branch }
      if r.valid?
        result[:id] = r.name.downcase.gsub(/[^a-z]/, '_').gsub(/_+/, '_').sub(/_$/, '')
        result[:version] = r.latest_local_commit
        result[:url] = r.url
        if r.upgrading?
          result[:upgrading] = true
          result[:version] = r.upgrade_version
        end
      end
      result
    end

    render json: {repos: repos}
  end

  def progress
    repo = GitRepo.new(params[:path])
    upgrader = Upgrader.new(current_user.id, repo, params[:version])
    render json: {progress: {logs: upgrader.find_logs, percentage: upgrader.last_percentage } }
  end

  def latest
    repo = GitRepo.new(params[:path])
    repo.update! if Rails.env == 'production'

    render json: {latest: {version: repo.latest_origin_commit,
                           commits_behind: repo.commits_behind,
                           date: repo.latest_origin_commit_date } }
  end

  def upgrade
    repo = GitRepo.new(params[:path])
    Thread.new do
      upgrader = Upgrader.new(current_user.id, repo, params[:version])
      upgrader.upgrade
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
    # Normally we don't run on OSX but this is useful for debugging
    if RUBY_PLATFORM =~ /darwin/
      ps_output = `ps aux -m`
    else
      ps_output = `ps aux --sort -rss`
    end
    render text: ps_output
  end
end
