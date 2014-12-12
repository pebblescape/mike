require 'spec_helper'

describe V1::UsersController, type: :controller do
  let(:user) { u = Fabricate.create(:user); u.ssh_keys << Fabricate.create(:ssh_key); u }

  context 'auth' do
    it "should return user info by key" do
      authenticated_request :get, 'auth', { key: user.ssh_keys.first.key }
      assert_response 200
      expect(response.body).to include(user.name)
    end

    it "should return user info by fingerprint" do
      authenticated_request :get, 'auth', { fingerprint: user.ssh_keys.first.fingerprint }
      assert_response 200
      expect(response.body).to include(user.name)
    end

    it "should return 404 on invalid key" do
      authenticated_request :get, 'auth', { key: 'bla' }
      assert_response 404
      expect(response.body).to include('invalid_ssh_key')
    end
  end
end
