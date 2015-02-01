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

  def push
    params.require(:cid)

    app = App.find_by_uuid_or_name(params[:app_id])
    build = Build.from_push(push_params, params[:cid], app, current_user)
    release = Release.from_push(build, app, current_user)

    release.deploy! unless app.name == 'mike' # TODO: add build-only apps

    render json: release, serializer: PushSerializer
  rescue Mike::BuildError => e
    json_error(422, 'failed_build', e.message)
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

  def push_params
    params.require(:build).permit(:commit)
  end
end
