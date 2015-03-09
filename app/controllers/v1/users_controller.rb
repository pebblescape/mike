class V1::UsersController < ApiController
  skip_before_filter :ensure_logged_in, only: [:login]

  def whoami
    render json: current_user
  end

  def login
    RateLimiter.new(nil, "login-hr-#{request.remote_ip}", 30, 1.hour).performed!
    RateLimiter.new(nil, "login-min-#{request.remote_ip}", 6, 1.minute).performed!

    if params[:user]
      params.require(:user).permit(:email, :password)
      username = params[:user][:email]
      password = params[:user][:password]
    else
      username = params.require(:username)
      password = params.require(:password)
    end

    return invalid_credentials if password.length > User.max_password_length

    login = username.strip
    login = login[1..-1] if login[0] == '@'

    if user = User.find_by_email(login)
      # If their password is correct
      unless user.confirm_password?(password)
        invalid_credentials
        return
      end
    else
      invalid_credentials
      return
    end

    render json: { api_key: user.api_key.key, email: user.email }
  end

  private

  def invalid_credentials
    json_error(401, 'login.incorrect_username_email_or_password')
  end
end
