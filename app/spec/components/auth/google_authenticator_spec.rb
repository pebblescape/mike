require 'spec_helper'

require_dependency 'auth/google_authenticator.rb'

describe Auth::GoogleAuthenticator do
  context 'after_authenticate' do
    it 'can authenticate and create a user record for already existing users' do
      authenticator = Auth::GoogleAuthenticator.new
      user = Fabricate(:user)

      hash = {
        "uid" => "100",
        :info => {
          "name" => "bob bob",
          "email" => user.email
        }
      }

      result = authenticator.after_authenticate(hash)
      result.user.id.should == user.id
    end

    it 'can create a proper result for non existing users' do
      hash = {
        "uid" => "100",
        :info => {
          "name" => "bob bob",
          "email" => "bob@bob.com",          
        }
      }

      authenticator = Auth::GoogleAuthenticator.new
      result = authenticator.after_authenticate(hash)

      result.user.should be_nil
      result.extra_data[:google_name].should == "bob bob"
    end
  end
end
