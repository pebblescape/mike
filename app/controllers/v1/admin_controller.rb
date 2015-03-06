require_dependency 'git_repo'
require_dependency 'upgrader'

class V1::AdminController < ApiController
  def repo
    result = {name: repo.name, path: repo.path, branch: repo.branch }

    if repo.valid?
      result[:id] = repo.name.downcase.gsub(/[^a-z]/, '_').gsub(/_+/, '_').sub(/_$/, '')
      result[:version] = repo.latest_local_commit
      result[:url] = repo.url
      if repo.upgrading?
        result[:upgrading] = true
        result[:version] = repo.upgrade_version
      end
    end

    render json: {repo: result}
  end

  def progress
    upgrader = Upgrader.new(current_user.id, repo, params[:version])
    render json: {progress: {logs: upgrader.find_logs, percentage: upgrader.last_percentage } }
  end

  def latest
    repo.update! if Rails.env == 'production'

    render json: {latest: {version: repo.latest_origin_commit,
                           commits_behind: repo.commits_behind,
                           date: repo.latest_origin_commit_date } }
  end

  def upgrade
    Thread.new do
      upgrader = Upgrader.new(current_user.id, repo, params[:version])
      upgrader.upgrade
    end
    render text: "OK"
  end

  def reset_upgrade
    upgrader = Upgrader.new(current_user.id, repo, params[:version])
    upgrader.reset!
    render text: "OK"
  end

  def ps
    if RUBY_PLATFORM =~ /darwin/
      ps_output = `ps aux -m`
    else
      ps_output = `ps aux --sort -rss`
    end
    render text: ps_output
  end

  private

  def repo
    @repo ||= GitRepo.new(Rails.root.to_s, 'mike')
  end
end
