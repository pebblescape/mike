class V1::ReleasesController < ApiController
  before_filter :fetch_app

  def index
    releases = @app.releases
    render json: releases
  end

  def create
    if params.has_key? :rollback
      if params[:rollback]
        find_release(params[:rollback])
      else
        @release = @app.releases[-2]
      end

      @release = @release.rollback!
    end

    render json: @release
  end

  def show
    params.require(:id)
    find_release(params[:id])
    raise Mike::NotFound unless @release

    # TODO: auth. app ownership check here
    render json: @release
  end

  private

  def fetch_app
    params.require(:app_id)
    @app = App.find_by_uuid_or_name(params[:app_id])
  end

  def find_release(id)
    if id == 'current'
      @release = @app.current_release
    elsif id =~ /v[0-9]+/
      @release = @app.releases.where(version: id[1..-1]).first
    else
      @release = @app.releases.find(id)
    end
  end
end
