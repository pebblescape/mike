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

      fakeinfo = {"process_types" => [{"web" => "bundle exec unicorn -p $PORT -c ./config/unicorn.rb"}],"app_size" => 128581632, "buildpack_name" => "Ruby"}
      container = double(Docker::Container)
      image = double(Docker::Image)
      expect(container).to receive(:info).and_return({"State" => {"ExitCode" => 0}})
      expect(container).to receive(:commit).and_return(image)
      expect(container).to receive(:remove).twice
      expect(container).to receive(:start)
      expect(container).to receive(:attach).and_return([[JSON.dump(fakeinfo)], []])

      expect(image).to receive(:tag).twice
      expect(image).to receive(:id).and_return(SecureRandom.hex)

      expect(Docker::Container).to receive(:get).and_return(container)
      expect(Docker::Container).to receive(:create).and_return(container)

      authenticated_request(:post, 'create', {app_id: app.id, cid: 'bogus', build: { commit: build['commit'] }}, user)

      assert_response 200
      expect(response.body).to include(build[:commit])
      expect(response.body).to include(fakeinfo['app_size'].to_s)
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
