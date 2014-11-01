require 'spec_helper'

describe StaticController, type: :controller do
  context 'show' do
    # context "with a static file that's present" do
    #   before do
    #     xhr :get, :show, id: 'faq'
    #   end
    # 
    #   it 'renders the static file if present' do
    #     response.should be_success
    #   end
    # 
    #   it "renders the file" do
    #     response.should render_template('static/show')
    #     assigns(:page).should == 'faq'
    #   end
    # end

    context "with a missing file" do
      it "should respond 404" do
        xhr :get, :show, id: 'does-not-exist'
        expect(response.response_code).to eq 404
      end
    end

    it 'should redirect to / when logged in and path is /login' do
      log_in
      xhr :get, :show, id: 'login'
      expect(response).to redirect_to '/'
    end

    it "should display the login template when login is required" do
      xhr :get, :show, id: 'login'
      expect(response).to be_success
    end
  end
  
  # describe '#enter' do
  #   context 'without a redirect path' do
  #     it 'redirects to the root url' do
  #       xhr :post, :enter
  #       expect(response).to redirect_to '/'
  #     end
  #   end
  # 
  #   context 'with a redirect path' do
  #     it 'redirects to the redirect path' do
  #       xhr :post, :enter, redirect: '/foo'
  #       expect(response).to redirect_to '/foo'
  #     end
  #   end
  # 
  #   context 'with a full url' do
  #     it 'redirects to the correct path' do
  #       xhr :post, :enter, redirect: "#{Discourse.base_url}/foo"
  #       expect(response).to redirect_to '/foo'
  #     end
  #   end
  # 
  #   context 'with a period to force a new host' do
  #     it 'redirects to the root path' do
  #       xhr :post, :enter, redirect: ".org/foo"
  #       expect(response).to redirect_to '/'
  #     end
  #   end
  # 
  #   context 'with a full url to someone else' do
  #     it 'redirects to the root path' do
  #       xhr :post, :enter, redirect: "http://eviltrout.com/foo"
  #       expect(response).to redirect_to '/'
  #     end
  #   end
  # 
  #   context 'with an invalid URL' do
  #     it "redirects to the root" do
  #       xhr :post, :enter, redirect: "javascript:alert('trout')"
  #       expect(response).to redirect_to '/'
  #     end
  #   end
  # 
  #   context 'when the redirect path is the login page' do
  #     it 'redirects to the root url' do
  #       xhr :post, :enter, redirect: login_path
  #       expect(response).to redirect_to '/'
  #     end
  #   end
  # end
end