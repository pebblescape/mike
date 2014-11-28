class V1::AppsController < ApiController
  def index
    render text: 'v1'
  end

  def show
    params.require(:id)

    app = App.find(params[:id])
    # TODO: app ownership check here
    render json: app
  end
end
