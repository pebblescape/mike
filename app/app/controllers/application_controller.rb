require 'current_user'
require_dependency 'mike'
# require_dependency 'crawler_detection'
# require_dependency 'json_error'

class ApplicationController < ActionController::Base
  include CurrentUser
  # include JsonError

  protect_from_forgery

  # Default Rails 3.2 lets the request through with a blank session
  #  we are being more pedantic here and nulling session / current_user
  #  and then raising a CSRF exception
  def handle_unverified_request
    # NOTE: API key is secret, having it invalidates the need for a CSRF token
    unless is_api?
      super
      clear_current_user
      render text: "['BAD CSRF']", status: 403
    end
  end

  before_filter :set_locale
  before_filter :set_mobile_view
  before_filter :authorize_mini_profiler
  before_filter :preload_json
  before_filter :check_xhr
  before_filter :redirect_to_login_if_required


  # rescue_from Exception do |exception|
  #   unless [ActiveRecord::RecordNotFound,
  #           ActionController::RoutingError,
  #           ActionController::UnknownController,
  #           AbstractController::ActionNotFound].include? exception.class
  #     begin
  #       ErrorLog.report_async!(exception, self, request, current_user)
  #     rescue
  #       # dont care give up
  #     end
  #   end
  #   raise
  # end

  # Some exceptions
  class RenderEmpty < Exception; end

  # Render nothing unless we are an xhr request
  rescue_from RenderEmpty do
    render 'default/empty'
  end

  rescue_from Mike::NotLoggedIn do |e|
    raise e if Rails.env.test?

    if request.get?
      redirect_to "/"
    else
      render status: 403, json: failed_json.merge(message: I18n.t(:not_logged_in))
    end
  end

  def set_locale
    I18n.locale = if SiteSetting.allow_user_locale && current_user && current_user.locale.present?
                    current_user.locale
                  else
                    SiteSetting.default_locale
                  end
  end

  def store_preloaded(key, json)
    @preloaded ||= {}
    # I dislike that there is a gsub as opposed to a gsub!
    #  but we can not be mucking with user input, I wonder if there is a way
    #  to inject this safty deeper in the library or even in AM serializer
    @preloaded[key] = json.gsub("</", "<\\/")
  end

  # If we are rendering HTML, preload the session data
  def preload_json
    # We don't preload JSON on xhr or JSON request
    return if request.xhr?

    preload_anonymous_data

    if current_user
      preload_current_user_data
    end
  end

  def set_mobile_view
    session[:mobile_view] = params[:mobile_view] if params.has_key?(:mobile_view)
  end

  def serialize_data(obj, serializer, opts={})
    # If it's an array, apply the serializer as an each_serializer to the elements
    if obj.respond_to?(:to_ary)
      opts[:each_serializer] = serializer
      ActiveModel::ArraySerializer.new(obj.to_ary, opts).as_json
    else
      serializer.new(obj, opts).as_json
    end
  end

  # This is odd, but it seems that in Rails `render json: obj` is about
  # 20% slower than calling MultiJSON.dump ourselves. I'm not sure why
  # Rails doesn't call MultiJson.dump when you pass it json: obj but
  # it seems we don't need whatever Rails is doing.
  def render_serialized(obj, serializer, opts={})
    render_json_dump(serialize_data(obj, serializer, opts))
  end

  def render_json_dump(obj)
    render json: MultiJson.dump(obj)
  end

  def can_cache_content?
    !current_user.present?
  end

  private
    def preload_anonymous_data
      store_preloaded("siteSettings", SiteSetting.client_settings_json)
    end

    def preload_current_user_data
      store_preloaded("currentUser", MultiJson.dump(CurrentUserSerializer.new(current_user, scope: guardian, root: false)))
    end

    def render_json_error(obj)
      render json: MultiJson.dump(create_errors_json(obj)), status: 422
    end

    def success_json
      {success: 'OK'}
    end

    def failed_json
      {failed: 'FAILED'}
    end

    def json_result(obj, opts={})
      if yield(obj)

        json = success_json

        # If we were given a serializer, add the class to the json that comes back
        if opts[:serializer].present?
          json[obj.class.name.underscore] = opts[:serializer].new(obj, scope: guardian).serializable_hash
        end

        render json: MultiJson.dump(json)
      else
        render_json_error(obj)
      end
    end

    def mini_profiler_enabled?
      defined?(Rack::MiniProfiler) && current_user.try(:admin?)
    end

    def authorize_mini_profiler
      return unless mini_profiler_enabled?
      Rack::MiniProfiler.authorize_request
    end

    def check_xhr
      # bypass xhr check on PUT / POST / DELETE provided api key is there, otherwise calling api is annoying
      return if !request.get? && api_key_valid?
      raise RenderEmpty.new unless ((request.format && request.format.json?) || request.xhr?)
    end

    def ensure_logged_in
      raise Mike::NotLoggedIn.new unless current_user.present?
    end

    def redirect_to_login_if_required
      return if current_user || (request.format.json? && api_key_valid?)

      redirect_to :login if SiteSetting.login_required?
    end

  protected

    def api_key_valid?
      request["api_key"] && ApiKey.where(key: request["api_key"]).exists?
    end
end
