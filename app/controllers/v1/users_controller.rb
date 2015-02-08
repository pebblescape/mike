class V1::UsersController < ApiController
  skip_before_filter :ensure_logged_in, only: [:login]

  def auth
    user = SshKey.where("key = ? OR fingerprint = ?", params[:key], params[:fingerprint]).first.try(:user)

    if user
      render json: user
    else
      json_error(404, 'invalid_ssh_key')
    end
  end

  def whoami
    render json: current_user
  end

  def login
    RateLimiter.new(nil, "login-hr-#{request.remote_ip}", 30, 1.hour).performed!
    RateLimiter.new(nil, "login-min-#{request.remote_ip}", 6, 1.minute).performed!

    params.require(:username)
    params.require(:password)

    return invalid_credentials if params[:password].length > User.max_password_length

    login = params[:username].strip
    login = login[1..-1] if login[0] == "@"

    if user = User.find_by_email(login)

      # If their password is correct
      unless user.confirm_password?(params[:password])
        invalid_credentials
        return
      end
    else
      invalid_credentials
      return
    end

    render json: { api_key: user.api_key.key }
  end

  private

  def invalid_credentials
    json_error(401, 'login.incorrect_username_email_or_password')
  end
end
