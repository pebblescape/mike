require_dependency 'rate_limiter'

class SessionController < ApplicationController
  skip_before_filter :redirect_to_login_if_required

  def csrf
    render json: {csrf: form_authenticity_token }
  end

  def create
    RateLimiter.new(nil, "login-hr-#{request.remote_ip}", 30, 1.hour).performed!
    RateLimiter.new(nil, "login-min-#{request.remote_ip}", 6, 1.minute).performed!

    params.require(:login)
    params.require(:password)

    return invalid_credentials if params[:password].length > User.max_password_length

    login = params[:login].strip
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

    login(user)
  end

  def forgot_password
    params.require(:login)

    RateLimiter.new(nil, "forgot-password-hr-#{request.remote_ip}", 6, 1.hour).performed!
    RateLimiter.new(nil, "forgot-password-min-#{request.remote_ip}", 3, 1.minute).performed!

    user = User.find_by_email(params[:login])
    if user.present?
      email_token = user.email_tokens.create(email: user.email)
      Jobs.enqueue(:user_email, type: :forgot_password, user_id: user.id, email_token: email_token.token)
    end

    render json: { result: "ok" }

  rescue RateLimiter::LimitExceeded
    json_error(429, I18n.t("rate_limiter.slow_down"))
  end

  def current
    if current_user.present?
      render json: current_user, serializer: CurrentUserSerializer
    else
      render nothing: true, status: 404
    end
  end

  def destroy
    reset_session
    log_off_user
    render nothing: true
  end

  private

  def invalid_credentials
    render json: {error: I18n.t("login.incorrect_username_email_or_password")}
  end

  def login(user)
    log_on_user(user)
    render json: current_user, serializer: CurrentUserSerializer
  end

end
