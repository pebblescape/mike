require 'current_user'
require_dependency 'mike'
require_dependency 'rate_limiter'

class ApplicationController < ActionController::Base
  include CurrentUser

  protect_from_forgery with: :null_session

  before_filter :authorize_mini_profiler
  before_filter :redirect_to_login_if_required

  rescue_from Mike::NotLoggedIn, Mike::InvalidAccess do |e|
    raise e if Rails.env.test?
    json_error(403, 'not_logged_in')
  end

  rescue_from Mike::NotFound do
    rescue_mike_actions("not_found", 404)
  end

  rescue_from RateLimiter::LimitExceeded do |e|

    time_left = ""
    if e.available_in < 1.minute.to_i
      time_left = I18n.t("rate_limiter.seconds", count: e.available_in)
    elsif e.available_in < 1.hour.to_i
      time_left = I18n.t("rate_limiter.minutes", count: (e.available_in / 1.minute.to_i))
    else
      time_left = I18n.t("rate_limiter.hours", count: (e.available_in / 1.hour.to_i))
    end

    render json: {error: I18n.t("rate_limiter.too_many_requests", time_left: time_left)}, status: 429
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: {error: e.message.gsub(/^Validation failed: /, '')}, status: 422
  end

  def handle_unverified_request
    # NOTE: API key is secret, having it invalidates the need for a CSRF token
    unless is_api?
      super
      clear_current_user
      json_error(403, 'bad_csrf')
    end
  end

  private

  def rescue_mike_actions(message, error)
    if request.format && request.format.json?
      json_error(error, message)
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

  def json_error(status=403, id='invalid_access', details=nil)
    json = { id: id, error: I18n.t("errors.#{id}")}
    json.merge({details:details}) if details
    render status: status, json: json
  end
end
