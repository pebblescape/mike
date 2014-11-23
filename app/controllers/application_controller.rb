require 'current_user'
require_dependency 'mike'

class ApplicationController < ActionController::Base
  include CurrentUser
  
  protect_from_forgery with: :null_session
  
  before_filter :authorize_mini_profiler
  before_filter :redirect_to_login_if_required
  
  rescue_from Mike::NotLoggedIn do |e|
    raise e if Rails.env.test?

    if request.get?
      redirect_to "/"
    else
      json_error(403, 'not_logged_in')
    end
  end
  
  rescue_from Mike::NotFound do
    rescue_mike_actions("[error: 'not found']", 404)
  end
  
  private
  
  def rescue_mike_actions(message, error, include_ember=false)
    if request.format && request.format.json?
      render status: error, layout: false, text: message
    else
      render text: build_not_found_page(error)
    end
  end
  
  def build_not_found_page(status=404)
    render_to_string status: status, formats: [:html], template: '/exceptions/not_found'
  end
  
  def mini_profiler_enabled?
    defined?(Rack::MiniProfiler)
  end

  def authorize_mini_profiler
    return unless mini_profiler_enabled?
    Rack::MiniProfiler.authorize_request
  end
  
  def redirect_to_login_if_required
    return if current_user

    redirect_to :login
  end
  
  def ensure_logged_in
    raise Mike::NotLoggedIn.new unless current_user.present?
  end
  
  def json_error(status=403, id='invalid_access')
    render status: status, json: { id: id, message: I18n.t("errors.#{id}")}
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
end
