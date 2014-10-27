require 'current_user'
require_dependency 'mike'

class ApiController < ApplicationController
  skip_before_filter :redirect_to_login_if_required
  before_filter :ensure_logged_in
  
  rescue_from Mike::NotLoggedIn do |e|
    raise e if Rails.env.test?

    json_error(403, 'not_logged_in')
  end
  
  protected

  def api_key_valid?
    request["api_key"] && ApiKey.where(key: request["api_key"]).exists?
  end
end
