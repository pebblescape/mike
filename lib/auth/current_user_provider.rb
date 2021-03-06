module Auth; end
class Auth::CurrentUserProvider

  # do all current user initialization here
  def initialize(env)
    raise NotImplementedError
  end

  # our current user, return nil if none is found
  def current_user
    raise NotImplementedError
  end

  # log on a user and set cookies and session etc.
  def log_on_user(user,session,cookies)
    raise NotImplementedError
  end

  def log_off_user(session, cookies)
    raise NotImplementedError
  end
end
