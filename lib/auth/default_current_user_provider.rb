require_dependency "auth/current_user_provider"

class Auth::DefaultCurrentUserProvider

  CURRENT_USER_KEY ||= "_MIKE_CURRENT_USER".freeze
  API_KEY ||= "api_key".freeze
  API_KEY_ENV ||= "_MIKE_API".freeze
  TOKEN_COOKIE ||= "_t".freeze
  PATH_INFO ||= "PATH_INFO".freeze

  # do all current user initialization here
  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
  end

  # our current user, return nil if none is found
  def current_user
    return @env[CURRENT_USER_KEY] if @env.key?(CURRENT_USER_KEY)

    request = @request

    auth_token = request.cookies[TOKEN_COOKIE]

    current_user = nil

    if auth_token && auth_token.length == 32
      current_user = User.find_by(auth_token: auth_token)
    end

    if current_user && !current_user.active
      current_user = nil
    end

    # possible we have an api call, impersonate
    if api_key = request[API_KEY]
      current_user = lookup_api_user(api_key, request)
      raise Mike::InvalidAccess unless current_user
      @env[API_KEY_ENV] = true
    end

    @env[CURRENT_USER_KEY] = current_user
  end

  def log_on_user(user, session, cookies)
    unless user.auth_token && user.auth_token.length == 32
      user.auth_token = SecureRandom.hex(16)
      user.save!
    end
    cookies.permanent[TOKEN_COOKIE] = { value: user.auth_token, httponly: true }
    @env[CURRENT_USER_KEY] = user
  end

  def log_off_user(session, cookies)
    cookies[TOKEN_COOKIE] = nil
  end

  # api has special rights return true if api was detected
  def is_api?
    current_user
    @env[API_KEY_ENV]
  end

  def has_auth_cookie?
    cookie = @request.cookies[TOKEN_COOKIE]
    !cookie.nil? && cookie.length == 32
  end

  protected

  def lookup_api_user(api_key_value, request)
    api_key = ApiKey.where(key: api_key_value).includes(:user).first
    if api_key
      api_email = request["api_email"]
      if api_key.user
        api_key.user if !api_email || (api_key.user.email == api_email.downcase)
      elsif api_email
        User.find_by(email: api_email.downcase)
      else
        nil
      end
    end
  end

end