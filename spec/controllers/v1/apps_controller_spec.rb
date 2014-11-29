require 'spec_helper'

describe V1::AppsController, type: :controller do
  let(:app) { Fabricate.create(:app) }
  let(:user) { user = Fabricate(:user) }

  context 'index' do
    it "should get user's apps" do
      user.apps << Fabricate(:app)
      user.apps << Fabricate(:app)

      authenticated_request(:get, 'index', {}, user)
      assert_response 200

      user.apps.each do |app|
        expect(response.body).to include(app.id)
      end
    end
  end

  context 'create' do
    it 'should create app' do
      newapp = Fabricate.attributes_for(:app)

      authenticated_request(:post, 'create', {app: newapp}, user)

      assert_response 200
      expect(response.body).to include(newapp[:name])
      expect(response.body).to include(user.id)
    end
  end

  context 'show' do
    it 'should return app info' do
      authenticated_request(:get, 'show', {id: app.id})

      assert_response 200
      expect(response.body).to include(app.id)
    end

    it 'respond to both names and uuids' do
      authenticated_request(:get, 'show', {id: app.id})
      assert_response 200
      expect(response.body).to include(app.id)

      authenticated_request(:get, 'show', {id: app.name})
      assert_response 200
      expect(response.body).to include(app.id)
    end

    it 'should not return too much owner info' do
      authenticated_request(:get, 'show', {id: app.id})

      assert_response 200
      expect(response.body).to include(app.id)
      expect(response.body).to include(app.owner.id)
      expect(response.body).to_not include(app.owner.salt)
    end
  end
end
