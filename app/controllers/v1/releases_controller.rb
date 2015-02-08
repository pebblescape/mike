class V1::ReleasesController < ApiController
  before_filter :fetch_app

  def index
    releases = @app.releases
    render json: releases
  end

  def create
    build = Build.create!(build_params)
    build.user = current_user
    build.app = @app
    build.save

    render json: build
  end

  def show
    params.require(:id)

    release = @app.releases.find(params[:id])
    # TODO: auth. app ownership check here
    render json: release
  end

  private

  def fetch_app
    params.require(:app_id)
    @app = App.find(params[:app_id])
  end
end
