require 'current_user'
require_dependency 'mike'
require_dependency 'rate_limiter'

class ApplicationController < ActionController::Base
  include CurrentUser

  protect_from_forgery with: :null_session

  rescue_from Mike::NotLoggedIn, Mike::InvalidAccess do |e|
    fail e if Rails.env.test?
    json_error(403, 'not_logged_in')
  end

  rescue_from Mike::NotFound do
    json_error(404, 'not_found')
  end

  rescue_from RateLimiter::LimitExceeded do |e|
    time_left = ''
    if e.available_in < 1.minute.to_i
      time_left = I18n.t('rate_limiter.seconds', count: e.available_in)
    elsif e.available_in < 1.hour.to_i
      time_left = I18n.t('rate_limiter.minutes', count: (e.available_in / 1.minute.to_i))
    else
      time_left = I18n.t('rate_limiter.hours', count: (e.available_in / 1.hour.to_i))
    end

    render json: { error: I18n.t('rate_limiter.too_many_requests', time_left: time_left) }, status: 429
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.message.gsub(/^Validation failed: /, '') }, status: 422
  end

  private

  def ensure_logged_in
    fail Mike::NotLoggedIn unless current_user.present?
  end

  def json_error(status=403, id='invalid_access', details=nil)
    json = { id: id, error: I18n.t('errors.#{id}') }
    json.merge(details: details) if details
    render status: status, json: json
  end
end
