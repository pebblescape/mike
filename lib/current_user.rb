module CurrentUser
  def self.lookup_from_env(env)
    Mike.current_user_provider.new(env).current_user
  end

  # can be used to pretend current user does no exist, for CSRF attacks
  def clear_current_user
    @current_user_provider = Mike.current_user_provider.new({})
  end

  def log_on_user(user)
    current_user_provider.log_on_user(user,session,cookies)
  end

  def log_off_user
    current_user_provider.log_off_user(session,cookies)
  end

  def current_user
    current_user_provider.current_user
  end

  private

  def current_user_provider
    @current_user_provider ||= Mike.current_user_provider.new(request.env)
  end
end
