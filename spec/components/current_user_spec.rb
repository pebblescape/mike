require 'spec_helper'
require_dependency 'current_user'

describe CurrentUser do
  it "allows us to lookup a user from our environment" do
    user = Fabricate(:user, auth_token: SecureRandom.hex(16), active: true)

    env = Rack::MockRequest.env_for("/test", "HTTP_COOKIE" => "_t=#{user.auth_token};")
    expect(CurrentUser.lookup_from_env(env)).to eq user
  end

end
