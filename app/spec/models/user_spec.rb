require 'spec_helper'
require_dependency 'user'

describe User do
  it { should validate_presence_of :username }
  it { should validate_presence_of :email }


  describe 'change_username' do
    let(:user) { Fabricate(:user) }

    context 'success' do
      let(:new_username) { "#{user.username}1234" }

      before do
        @result = user.change_username(new_username)
      end

      it 'returns true' do
        @result.should be_true
      end

      it 'should change the username' do
        user.reload
        user.username.should == new_username
      end

      it 'should change the username_lower' do
        user.reload
        user.username_lower.should == new_username.downcase
      end
    end

    context 'failure' do
      let(:wrong_username) { "" }
      let(:username_before_change) { user.username }
      let(:username_lower_before_change) { user.username_lower }

      before do
        @result = user.change_username(wrong_username)
      end

      it 'returns false' do
        @result.should be_false
      end

      it 'should not change the username' do
        user.reload
        user.username.should == username_before_change
      end

      it 'should not change the username_lower' do
        user.reload
        user.username_lower.should == username_lower_before_change
      end
    end

    describe 'change the case of my username' do
      let!(:myself) { Fabricate(:user, username: 'hansolo') }

      it 'should return true' do
        myself.change_username('HanSolo').should be_true
      end

      it 'should change the username' do
        myself.change_username('HanSolo')
        myself.reload.username.should == 'HanSolo'
      end
    end

    describe 'allow custom minimum username length from site settings' do
      before do
        @custom_min = User.username_length.begin - 1
        SiteSetting.stubs("min_username_length").returns(@custom_min)
      end

      it 'should allow a shorter username than default' do
        result = user.change_username('a' * @custom_min)
        result.should_not be_false
      end

      it 'should not allow a shorter username than limit' do
        result = user.change_username('a' * (@custom_min - 1))
        result.should be_false
      end

      it 'should not allow a longer username than limit' do
        result = user.change_username('a' * (User.username_length.end + 1))
        result.should be_false
      end
    end
  end

  describe 'new' do
    subject { Fabricate.build(:user) }

    it { should be_valid }
    it { should_not be_admin }
  end

  describe 'temporary_key' do
    let(:user) { Fabricate(:user) }
    let!(:temporary_key) { user.temporary_key}

    it 'has a temporary key' do
      temporary_key.should be_present
    end

    describe 'User#find_by_temporary_key' do
      it 'can be used to find the user' do
        User.find_by_temporary_key(temporary_key).should == user
      end

      it 'returns nil with an invalid key' do
        User.find_by_temporary_key('asdfasdf').should be_blank
      end
    end
  end

  describe 'email_hash' do
    before do
      @user = Fabricate(:user)
    end

    it 'should have a sane email hash' do
      @user.email_hash.should =~ /^[0-9a-f]{32}$/
    end

    it 'should use downcase email' do
      @user.email = "example@example.com"
      @user2 = Fabricate(:user)
      @user2.email = "ExAmPlE@eXaMpLe.com"

      @user.email_hash.should == @user2.email_hash
    end

    it 'should trim whitespace before hashing' do
      @user.email = "example@example.com"
      @user2 = Fabricate(:user)
      @user2.email = " example@example.com "

      @user.email_hash.should == @user2.email_hash
    end
  end

  describe 'name heuristics' do
    it 'is able to guess a decent name from an email' do
      User.suggest_name('sam.saffron@gmail.com').should == 'Sam Saffron'
    end
  end

  describe 'username format' do
    it "should be #{SiteSetting.min_username_length} chars or longer" do
      @user = Fabricate.build(:user)
      @user.username = 'ss'
      @user.save.should == false
    end

    it "should never end with a ." do
      @user = Fabricate.build(:user)
      @user.username = 'sam.'
      @user.save.should == false
    end

    it "should never contain spaces" do
      @user = Fabricate.build(:user)
      @user.username = 'sam s'
      @user.save.should == false
    end

    ['Bad One', 'Giraf%fe', 'Hello!', '@twitter', 'me@example.com', 'no.dots', 'purple.', '.bilbo', '_nope', 'sa$sy'].each do |bad_nickname|
      it "should not allow username '#{bad_nickname}'" do
        @user = Fabricate.build(:user)
        @user.username = bad_nickname
        @user.save.should == false
      end
    end
  end

  describe 'username uniqueness' do
    before do
      @user = Fabricate.build(:user)
      @user.save!
      @codinghorror = Fabricate.build(:coding_horror)
    end

    it "should not allow saving if username is reused" do
       @codinghorror.username = @user.username
       @codinghorror.save.should be_false
    end

    it "should not allow saving if username is reused in different casing" do
       @codinghorror.username = @user.username.upcase
       @codinghorror.save.should be_false
    end
  end

  context '.username_available?' do
    it "returns true for a username that is available" do
      User.username_available?('BruceWayne').should be_true
    end

    it 'returns false when a username is taken' do
      User.username_available?(Fabricate(:user).username).should be_false
    end
  end

  describe 'email_validator' do
    it 'should allow good emails' do
      user = Fabricate.build(:user, email: 'good@gmail.com')
      user.should be_valid
    end

    it 'should reject some emails based on the email_domains_blacklist site setting' do
      SiteSetting.stubs(:email_domains_blacklist).returns('mailinator.com')
      Fabricate.build(:user, email: 'notgood@mailinator.com').should_not be_valid
      Fabricate.build(:user, email: 'mailinator@gmail.com').should be_valid
    end

    it 'should reject some emails based on the email_domains_blacklist site setting' do
      SiteSetting.stubs(:email_domains_blacklist).returns('mailinator.com|trashmail.net')
      Fabricate.build(:user, email: 'notgood@mailinator.com').should_not be_valid
      Fabricate.build(:user, email: 'notgood@trashmail.net').should_not be_valid
      Fabricate.build(:user, email: 'mailinator.com@gmail.com').should be_valid
    end

    it 'should not reject partial matches' do
      SiteSetting.stubs(:email_domains_blacklist).returns('mail.com')
      Fabricate.build(:user, email: 'mailinator@gmail.com').should be_valid
    end

    it 'should reject some emails based on the email_domains_blacklist site setting ignoring case' do
      SiteSetting.stubs(:email_domains_blacklist).returns('trashmail.net')
      Fabricate.build(:user, email: 'notgood@TRASHMAIL.NET').should_not be_valid
    end

    it 'should not interpret a period as a wildcard' do
      SiteSetting.stubs(:email_domains_blacklist).returns('trashmail.net')
      Fabricate.build(:user, email: 'good@trashmailinet.com').should be_valid
    end

    it 'should not be used to validate existing records' do
      u = Fabricate(:user, email: 'in_before_blacklisted@fakemail.com')
      SiteSetting.stubs(:email_domains_blacklist).returns('fakemail.com')
      u.should be_valid
    end

    it 'should be used when email is being changed' do
      SiteSetting.stubs(:email_domains_blacklist).returns('mailinator.com')
      u = Fabricate(:user, email: 'good@gmail.com')
      u.email = 'nope@mailinator.com'
      u.should_not be_valid
    end

    it 'whitelist should reject some emails based on the email_domains_whitelist site setting' do
      SiteSetting.stubs(:email_domains_whitelist).returns('vaynermedia.com')
      Fabricate.build(:user, email: 'notgood@mailinator.com').should_not be_valid
      Fabricate.build(:user, email: 'sbauch@vaynermedia.com').should be_valid
    end

    it 'should reject some emails based on the email_domains_whitelist site setting when whitelisting multiple domains' do
      SiteSetting.stubs(:email_domains_whitelist).returns('vaynermedia.com|gmail.com')
      Fabricate.build(:user, email: 'notgood@mailinator.com').should_not be_valid
      Fabricate.build(:user, email: 'notgood@trashmail.net').should_not be_valid
      Fabricate.build(:user, email: 'mailinator.com@gmail.com').should be_valid
      Fabricate.build(:user, email: 'mailinator.com@vaynermedia.com').should be_valid
    end

    it 'should accept some emails based on the email_domains_whitelist site setting ignoring case' do
      SiteSetting.stubs(:email_domains_whitelist).returns('vaynermedia.com')
      Fabricate.build(:user, email: 'good@VAYNERMEDIA.COM').should be_valid
    end

    it 'email whitelist should not be used to validate existing records' do
      u = Fabricate(:user, email: 'in_before_whitelisted@fakemail.com')
      SiteSetting.stubs(:email_domains_blacklist).returns('vaynermedia.com')
      u.should be_valid
    end

    it 'email whitelist should be used when email is being changed' do
      SiteSetting.stubs(:email_domains_whitelist).returns('vaynermedia.com')
      u = Fabricate(:user, email: 'good@vaynermedia.com')
      u.email = 'nope@mailinator.com'
      u.should_not be_valid
    end
  end

  describe 'passwords' do
    before do
      @user = Fabricate.build(:user)
      @user.password = "ilovepasta"
      @user.save!
    end

    it "should have a valid password after the initial save" do
      @user.confirm_password?("ilovepasta").should be_true
    end
  end

  describe "previous_visit_at" do
    let(:user) { Fabricate(:user) }
    let!(:first_visit_date) { Time.zone.now }
    let!(:second_visit_date) { 2.hours.from_now }
    let!(:third_visit_date) { 5.hours.from_now }

    before do
      SiteSetting.stubs(:active_user_rate_limit_secs).returns(0)
      SiteSetting.stubs(:previous_visit_timeout_hours).returns(1)
    end

    it "should act correctly" do
      user.previous_visit_at.should be_nil

      # first visit
      user.update_last_seen!(first_visit_date)
      user.previous_visit_at.should be_nil

      # updated same time
      user.update_last_seen!(first_visit_date)
      user.reload
      user.previous_visit_at.should be_nil

      # second visit
      user.update_last_seen!(second_visit_date)
      user.reload
      user.previous_visit_at.should be_within_one_second_of(first_visit_date)

      # third visit
      user.update_last_seen!(third_visit_date)
      user.reload
      user.previous_visit_at.should be_within_one_second_of(second_visit_date)
    end
  end

  describe "last_seen_at" do
    let(:user) { Fabricate(:user) }

    it "should have a blank last seen on creation" do
      user.last_seen_at.should be_nil
    end

    describe 'with no previous values' do
      let!(:date) { Time.zone.now }

      before do
        Timecop.freeze(date)
        user.update_last_seen!
      end

      after do
        Timecop.return
      end

      it "updates last_seen_at" do
        user.last_seen_at.should be_within_one_second_of(date)
      end
    end
  end

  describe '#readable_name' do
    context 'when name is missing' do
      it 'returns just the username' do
        Fabricate(:user, username: 'foo', name: nil).readable_name.should == 'foo'
      end
    end
    context 'when name and username are identical' do
      it 'returns just the username' do
        Fabricate(:user, username: 'foo', name: 'foo').readable_name.should == 'foo'
      end
    end
    context 'when name and username are not identical' do
      it 'returns the name and username' do
        Fabricate(:user, username: 'foo', name: 'Bar Baz').readable_name.should == 'Bar Baz (foo)'
      end
    end
  end

  describe '.find_by_username_or_email' do
    it 'finds users' do
      bob = Fabricate(:user, username: 'bob', email: 'bob@example.com')
      found_user = User.find_by_username_or_email('Bob')
      expect(found_user).to eq bob

      found_user = User.find_by_username_or_email('bob@Example.com')
      expect(found_user).to eq bob

      found_user = User.find_by_username_or_email('Bob@Example.com')
      expect(found_user).to be_nil

      found_user = User.find_by_username_or_email('bob1')
      expect(found_user).to be_nil

      found_user = User.find_by_email('bob@Example.com')
      expect(found_user).to eq bob

      found_user = User.find_by_email('bob')
      expect(found_user).to be_nil

      found_user = User.find_by_username('bOb')
      expect(found_user).to eq bob
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
      User.gravatar_template("em@il.com").should == "//www.gravatar.com/avatar/6dc2fde946483a1d8a84b89345a1b638.png?s={size}&r=pg&d=identicon"
    end
  end
end
