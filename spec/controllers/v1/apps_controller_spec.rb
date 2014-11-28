require 'spec_helper'

describe V1::AppsController, type: :controller do
  let(:app) { Fabricate.create(:app) }

  context 'index' do
    it "should get v1" do
      authenticated_request(:get, 'index')
      assert_response 200
      expect(response.body).to eq("v1")
    end
  end

  context 'show' do
    it 'should return app info' do
      authenticated_request(:get, 'show', {id: app.id})
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
