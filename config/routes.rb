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

  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.pebblescape+json; version=1"}) do
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

    get 'auth' => 'users#auth'
    post 'login' => 'users#login'
    get 'user' => 'users#whoami'
  end

  resources :session, id: USERNAME_ROUTE_FORMAT, only: [:create, :destroy, :become] do
    collection do
      post "forgot_password"
    end
  end

  get "session/current" => "session#current"
  get "session/csrf" => "session#csrf"

  root "apps#index"
end
