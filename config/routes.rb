require "sidekiq/web"
require_dependency "admin_constraint"

USERNAME_ROUTE_FORMAT = /[A-Za-z0-9\_]+/ unless defined? USERNAME_ROUTE_FORMAT

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  else
    mount Sidekiq::Web => "/sidekiq", constraints: AdminConstraint.new
  end

  # /app.git/
  mount Grack::Bundle.new({
    project_root: Mike.repo_path,
    upload_pack:  true,
    receive_pack: true
  }), at: '/', constraints: lambda { |request| /^\/[\w\.]+\.git\//.match(request.path_info) }, via: [:get, :post]

  api_version(:module => "V1", :path => {:value => "api"}, :header => {:name => "Accept", :value => "application/vnd.pebblescape+json; version=1"}) do
    resources :apps do
      resources :builds
      resources :releases, only: [:index, :show, :create]
      resource :config_vars, only: [:show, :update] do
        member do
          delete ':id' => 'config_vars#destroy'
        end
      end

      post :push
    end
    resources :users

    post 'admin/upgrade' => 'admin#upgrade'
    delete 'admin/upgrade' => 'admin#reset_upgrade'
    get 'admin/latest' => 'admin#latest'
    get 'admin/gitinfo' => 'admin#gitinfo'
    get 'admin/progress' => 'admin#progress'
    get 'admin/ps' => 'admin#ps'

    post 'login' => 'users#login'
    get 'user' => 'users#whoami'
  end

  root "landing#index"
end
