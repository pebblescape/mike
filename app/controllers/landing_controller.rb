require_dependency 'dashboard_index'

class LandingController < ApplicationController
  def index
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    if File.exist?(Rails.root.join("public/index.html"))
      render file: "#{Rails.root}/public/index.html", layout: false
    else
      cache_index
    end
  end

  private

  def cache_index
    version = params[:dashboard_ref] || 'master'
    key = "dashboardindex-#{version}"

    cached = Rails.cache.read(key)
    return cached if cached

    begin
      html = DashboardIndex.cache_latest(version)
      render text: html, layout: false
    rescue
      render file: "#{Rails.root}/public/404.html", layout: false
    end
  end
end
