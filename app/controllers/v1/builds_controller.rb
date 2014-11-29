class V1::BuildsController < ApiController
  before_filter :fetch_app

  def index
    builds = @app.builds
    render json: builds
  end

  def create
    build = Build.create(build_params)
    build.user = current_user
    build.save

    render json: build
  end

  def show
    params.require(:id)

    build = Build.find(params[:id])
    # TODO: auth. app ownership check here
    render json: build
  end

  private

  # TODO: whitelist this
  def build_params
    params.require(:build).permit!
  end

  def fetch_app
    params.require(:app_id)
    @app = App.find(params[:app_id])
  end
end
