require 'spec_helper'

describe V1::BuildsController, type: :controller do
  let(:user) { Fabricate(:user) }
  let(:app) { Fabricate(:app, owner: user) }
  let(:build) { Fabricate(:build, app: app, user: user) }

  context 'index' do
    it "should get the app's builds" do
      app.builds << Fabricate(:build, app: app, user: user)
      app.builds << Fabricate(:build, app: app, user: user)

      authenticated_request(:get, 'index', {app_id: app.id}, user)
      assert_response 200

      app.builds.each do |build|
        expect(response.body).to include(build.id)
      end
    end
  end

  context 'create' do
    it 'should create build' do
      build = Fabricate.attributes_for(:build, app: app)

      authenticated_request(:post, 'create', {app_id: app.id, build: build}, user)

      assert_response 200
      expect(response.body).to include(build[:commit])
      expect(response.body).to include(user.id)
      expect(response.body).to include(app.id)
    end
  end

  context 'show' do
    it 'should return build info' do
      authenticated_request(:get, 'show', {app_id: app.id, id: build.id})

      assert_response 200
      expect(response.body).to include(build.id)
    end

    it 'should not return too much owner info' do
      authenticated_request(:get, 'show', {app_id: app.id, id: build.id})

      assert_response 200
      expect(response.body).to include(build.id)
      expect(response.body).to include(build.user.id)
      expect(response.body).to_not include(build.user.salt)
    end
  end
end
