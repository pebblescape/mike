class V1::AppsController < ApiController
  def index
    apps = current_user.apps
    render json: apps
  end

  def create
    app = App.create!(app_params)
    app.owner = current_user
    app.save

    render json: app
  end

  def show
    params.require(:id)

    app = App.find_by_uuid_or_name(params[:id])
    raise Mike::NotFound unless app
    # TODO: auth. app ownership check here
    render json: app
  end

  private

  def app_params
    params.require(:app).permit(:name, :config_vars)
  end
end
