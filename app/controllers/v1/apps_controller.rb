class V1::AppsController < ApiController
  def index
    apps = current_user.apps
    render json: apps
  end

  def create
    app = App.create(app_params)
    app.owner = current_user
    app.save

    render json: app
  end

  def show
    params.require(:id)

    app = App.find(params[:id])
    # TODO: auth. app ownership check here
    render json: app
  end

  private

  # TODO: whitelist this
  def app_params
    params.require(:app).permit!
  end
end
