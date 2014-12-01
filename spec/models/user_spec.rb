require 'spec_helper'
require_dependency 'user'

describe User do
  it { should validate_presence_of :login }
  it { should validate_presence_of :email }

  describe 'new' do
    subject { Fabricate.build(:user) }

    it { should be_valid }
    it { should_not be_admin }

    it "downcases email addresses" do
      user = Fabricate.build(:user, email: 'Fancy.Caps.4.U@gmail.com')
      user.save
      expect(user.reload.email).to eq 'fancy.caps.4.u@gmail.com'
    end
  end

  describe 'temporary_key' do
    let(:user) { Fabricate(:user) }
    let!(:temporary_key) { user.temporary_key}

    it 'has a temporary key' do
      expect(temporary_key).to be_present
    end

    describe 'User#find_by_temporary_key' do
      it 'can be used to find the user' do
        expect(User.find_by_temporary_key(temporary_key)).to eq user
      end

      it 'returns nil with an invalid key' do
        expect(User.find_by_temporary_key('asdfasdf')).to be_blank
      end
    end
  end

  describe 'email_hash' do
    before do
      @user = Fabricate(:user)
    end

    it 'should have a sane email hash' do
      expect(@user.email_hash).to match /^[0-9a-f]{32}$/
    end

    it 'should use downcase email' do
      @user.email = "example@example.com"
      @user2 = Fabricate(:user)
      @user2.email = "ExAmPlE@eXaMpLe.com"

      expect(@user.email_hash).to eq @user2.email_hash
    end

    it 'should trim whitespace before hashing' do
      @user.email = "example@example.com"
      @user2 = Fabricate(:user)
      @user2.email = " example@example.com "

      expect(@user.email_hash).to eq @user2.email_hash
    end
  end

  describe 'passwords' do
    before do
      @user = Fabricate.build(:user, active: false)
      @user.password = "ilovepasta"
      @user.save!
    end

    it "should have a valid password after the initial save" do
      expect(@user.confirm_password?("ilovepasta")).to eq true
    end

    it "should not have an active account after initial save" do
      expect(@user.active).to eq false
    end
  end

  describe 'api keys' do
    let(:admin) { Fabricate(:admin) }
    let(:other_admin) { Fabricate(:admin) }
    let(:user) { Fabricate(:user) }

    describe '.generate_api_key' do
      it "generates an api key when none exists, and regenerates when it does" do
        expect(user.api_key).to be_blank

        # Generate a key
        api_key = user.generate_api_key(admin)
        expect(api_key.user).to eq(user)
        expect(api_key.key).to be_present
        expect(api_key.created_by).to eq(admin)

        user.reload
        expect(user.api_key).to eq(api_key)

        # Regenerate a key. Keeps the same record, updates the key
        new_key = user.generate_api_key(other_admin)
        expect(new_key.id).to eq(api_key.id)
        expect(new_key.key).to_not eq(api_key.key)
        expect(new_key.created_by).to eq(other_admin)
      end
    end

    describe '.revoke_api_key' do
      it "revokes an api key when exists" do
        expect(user.api_key).to be_blank

        # Revoke nothing does nothing
        user.revoke_api_key
        user.reload
        expect(user.api_key).to be_blank

        # When a key is present it is removed
        user.generate_api_key(admin)
        user.reload
        user.revoke_api_key
        user.reload
        expect(user.api_key).to be_blank
      end
    end
  end

  describe "#gravatar_template" do
    it "returns a gravatar based template" do
      expect(User.gravatar_template("em@il.com")).to eq "//www.gravatar.com/avatar/6dc2fde946483a1d8a84b89345a1b638.png?s={size}&r=pg&d=identicon"
    end
  end
end
