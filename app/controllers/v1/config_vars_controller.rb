class V1::ConfigVarsController < ApiController
  before_filter :fetch_app

  def show
    render json: @app.config_vars
  end

  def update
    config = MultiJson.load(request.body.read)

    config.each do |k, v|
      @app.config_vars[k] = v
    end

    if @app.save
      redeploy("Set #{config.keys.join(', ')} config var#{config.length > 1 ? 's' : ''}")

      render json: @app.config_vars
    else
      json_error(422, 'failed_update', @app.errors)
    end
  rescue MultiJson::ParseError
    json_error(422, 'json_body_invalid', @app.errors)
  end

  def destroy
    @app.config_vars.delete(params[:id])

    if @app.save
      redeploy("Unset #{params[:id]} config var")

      render json: @app.config_vars
    else
      json_error(422, 'failed_update', @app.errors)
    end
  end

  private

  def fetch_app
    params.require(:app_id)
    @app = App.find_by_uuid_or_name(params[:app_id])
  end

  def redeploy(message)
    release = Release.from_config(message, @app, current_user)
    release.deploy!
  end
end
