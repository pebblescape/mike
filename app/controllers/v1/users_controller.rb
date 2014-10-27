class V1::UsersController < ApiController
  skip_before_filter :ensure_logged_in, only: [:auth]
  
  def auth
    user = SshKey.where("key = ? OR fingerprint = ?", params[:key], params[:fingerprint]).first.try(:user)
    
    if user
      render json: user
    else
      json_error(404, 'invalid_ssh_key')
    end
  end
end