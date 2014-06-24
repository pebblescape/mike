require 'spec_helper'

describe V1::AppsController, type: :controller do
  context 'index' do
    it "should get v1" do
      get 'index', {}, {'Accept' => 'application/vnd.pebblescape+json; version=1'}
      assert_response 200
      assert_equal "v1", response.body
    end
  end
end
