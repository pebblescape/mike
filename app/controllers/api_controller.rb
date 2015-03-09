require 'current_user'
require_dependency 'mike'

class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :ensure_logged_in
end
