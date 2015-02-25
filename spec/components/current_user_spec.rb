require 'spec_helper'
require_dependency 'current_user'

describe CurrentUser do
  it "allows us to lookup a user from our environment" do
    key = Fabricate(:api_key)
    user = Fabricate(:user, api_key: key)

    env = Rack::MockRequest.env_for("/test", "HTTP_AUTHORIZATION" => "Token api_key=\"#{key.key}\", email=\"#{user.email}\";")
    expect(CurrentUser.lookup_from_env(env)).to eq user
  end

end
