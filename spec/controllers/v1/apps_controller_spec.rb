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

  context 'push' do
    it 'should process a push' do
      build = Fabricate.attributes_for(:build, app: app)

      fakeinfo = {"process_types" => [{"web" => "bundle exec unicorn -p $PORT -c ./config/unicorn.rb"}],"app_size" => 128581632, "buildpack_name" => "Ruby"}
      container = double(Docker::Container)
      image = double(Docker::Image)
      expect(container).to receive(:info).and_return({"State" => {"ExitCode" => 0}})
      expect(container).to receive(:json).and_return({"State" => {"ExitCode" => 0}, "NetworkSettings" => {"IPAddress" => "127.0.0.1"}})
      expect(container).to receive(:commit).and_return(image)
      expect(container).to receive(:remove).twice
      expect(container).to receive(:start).twice.and_return(container)
      expect(container).to receive(:id).and_return(SecureRandom.hex)
      expect(container).to receive(:attach).and_return([[JSON.dump(fakeinfo)], []])

      expect(image).to receive(:tag).twice
      expect(image).to receive(:id).twice.and_return(SecureRandom.hex)

      expect(Docker::Container).to receive(:get).and_return(container)
      expect(Docker::Container).to receive(:create).twice.and_return(container)

      authenticated_request(:post, 'push', {app_id: app.id, cid: 'bogus', build: { commit: build['commit'], status: build[:status] }}, user)

      assert_response 200
      expect(response.body).to include(build[:commit])
      expect(response.body).to include(user.id)
      expect(response.body).to include(app.id)
    end
  end
end
