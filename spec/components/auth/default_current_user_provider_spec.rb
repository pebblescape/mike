require 'spec_helper'
require_dependency 'auth/default_current_user_provider'

describe Auth::DefaultCurrentUserProvider do

  def provider(url, opts=nil)
    opts ||= {method: "GET"}
    env = Rack::MockRequest.env_for(url, opts)
    Auth::DefaultCurrentUserProvider.new(env)
  end

  it "raises errors for incorrect api_key" do
    expect{
      provider("/?api_key=INCORRECT").current_user
    }.to raise_error(Mike::InvalidAccess)
  end

  it "finds a user for a correct per-user api key" do
    user = Fabricate(:user)
    ApiKey.create!(key: "hello", user_id: user.id, created_by_id: Mike::SYSTEM_USER_ID)
    expect(provider("/?api_key=hello").current_user.id).to eq user.id
  end

  it "raises for a user pretending" do
    user = Fabricate(:user)
    user2 = Fabricate(:user)
    ApiKey.create!(key: "hello", user_id: user.id, created_by_id: Mike::SYSTEM_USER_ID)

    expect{
      provider("/?api_key=hello&api_email=#{user2.email}").current_user
    }.to raise_error(Mike::InvalidAccess)
  end

  it "finds a user for a correct system api key" do
    user = Fabricate(:user)
    ApiKey.create!(key: "hello", created_by_id: Mike::SYSTEM_USER_ID)
    expect(provider("/?api_key=hello&api_email=#{user.email}").current_user.id).to eq user.id
  end
end

