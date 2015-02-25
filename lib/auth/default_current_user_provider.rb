require_dependency "auth/current_user_provider"

class Auth::DefaultCurrentUserProvider
  TOKEN_KEY = 'api_key='
  TOKEN_REGEX = /^Token /
  AUTHN_PAIR_DELIMITERS = /(?:,|;|\t+)/

  CURRENT_USER_KEY ||= "_MIKE_CURRENT_USER".freeze
  API_KEY ||= "api_key".freeze

  # do all current user initialization here
  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
  end

  # our current user, return nil if none is found
  def current_user
    return @env[CURRENT_USER_KEY] if @env.key?(CURRENT_USER_KEY)

    request = @request
    current_user = nil

    if current_user && !current_user.active
      current_user = nil
    end

    token, options = token_and_options
    if authorization
      current_user = lookup_api_user(token, options['email'])
      raise Mike::InvalidAccess unless current_user
    end

    # possible we have an api call, impersonate
    if api_key = request[API_KEY]
      current_user = lookup_api_user(api_key, request["api_login"])
      raise Mike::InvalidAccess unless current_user
    end

    @env[CURRENT_USER_KEY] = current_user
  end

  def log_on_user(user, session, cookies)
    @env[CURRENT_USER_KEY] = user
  end

  private

  def token_and_options
    authorization_request = authorization.to_s
    if authorization_request[TOKEN_REGEX]
      params = token_params_from authorization_request
      [params.shift[1], Hash[params].with_indifferent_access]
    end
  end

  def token_params_from(auth)
    rewrite_param_values params_array_from raw_params auth
  end

  # Takes raw_params and turns it into an array of parameters
  def params_array_from(raw_params)
    raw_params.map { |param| param.split %r/=(.+)?/ }
  end

  # This removes the <tt>"</tt> characters wrapping the value.
  def rewrite_param_values(array_params)
    array_params.each { |param| (param[1] || "").gsub! %r/^"|"$/, '' }
  end

  # This method takes an authorization body and splits up the key-value
  # pairs by the standardized <tt>:</tt>, <tt>;</tt>, or <tt>\t</tt>
  # delimiters defined in +AUTHN_PAIR_DELIMITERS+.
  def raw_params(auth)
    _raw_params = auth.sub(TOKEN_REGEX, '').split(/\s*#{AUTHN_PAIR_DELIMITERS}\s*/)

    if !(_raw_params.first =~ %r{\A#{TOKEN_KEY}})
      _raw_params[0] = "#{TOKEN_KEY}#{_raw_params.first}"
    end

    _raw_params
  end

  def authorization
    @env['HTTP_AUTHORIZATION']   ||
    @env['X-HTTP_AUTHORIZATION'] ||
    @env['X_HTTP_AUTHORIZATION'] ||
    @env['REDIRECT_X_HTTP_AUTHORIZATION']
  end

  protected

  def lookup_api_user(api_key_value, api_login)
    api_key = ApiKey.where(key: api_key_value).includes(:user).first
    if api_key
      if api_key.user
        api_key.user if !api_login || (api_key.user.email == api_login.downcase)
      elsif api_login
        User.find_by(email: api_login.downcase)
      else
        Mike.system_user
      end
    end
  end

end
