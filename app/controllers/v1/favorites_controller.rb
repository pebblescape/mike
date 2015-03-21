class V1::FavoritesController < ApiController
  before_filter :fetch_app, only: [:destroy]

  def index
    apps = current_user.apps
    render json: apps
  end

  def create
    # app = App.create!(app_params)
    # app.owner = current_user
    # app.save

    render json: app, status: 201
  end

  def destroy
    fail Mike::NotFound unless @app

    render json: @app
  end

  private

  def fetch_app
    params.require(:id)
    @app = App.find_by_uuid_or_name(params[:id])
  end
end
