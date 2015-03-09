class V1::AppsController < ApiController
  before_filter :fetch_app, only: [:show, :destroy]

  def index
    apps = current_user.apps
    render json: apps
  end

  def create
    app = App.create!(app_params)
    app.owner = current_user
    app.save

    render json: app, status: 201
  end

  def push
    params.require(:cid)

    app = App.find_by_uuid_or_name(params[:app_id])
    build = Build.from_push(push_params, params[:cid], app, current_user)
    release = Release.from_push(build, app, current_user)
    release.deploy!

    render json: release, serializer: PushSerializer
  rescue Mike::BuildError => e
    json_error(422, 'failed_build', e.message)
  end

  def show
    fail Mike::NotFound unless @app
    # TODO: auth. app ownership check here
    render json: @app
  end

  def destroy
    fail Mike::NotFound unless @app

    # TODO: auth. app ownership check here
    @app.destroy

    render json: @app
  end

  private

  def fetch_app
    params.require(:id)
    @app = App.find_by_uuid_or_name(params[:id])
  end

  def app_params
    params.require(:app).permit(:name, :config_vars)
  end

  def push_params
    params.require(:build).permit(:commit)
  end
end
