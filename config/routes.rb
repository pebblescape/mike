require "sidekiq/web"
require_dependency "admin_constraint"

USERNAME_ROUTE_FORMAT = /[A-Za-z0-9\_]+/ unless defined? USERNAME_ROUTE_FORMAT

Rails.application.routes.draw do
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == 'admin' && password == ENV["SIDEKIQ_PASSWORD"]
    end
  end

  mount Sidekiq::Web => "/sidekiq"

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
    resources :favorites
    resources :users

    get "admin/ps" => "admin#ps"
    get "admin/upgrades" => "admin#upgrades"
    get "admin/latest" => "admin#latest"
    get "admin/progress" => "admin#progress"
    post "admin/upgrade" => "admin#upgrade"
    delete "admin/upgrade" => "admin#reset_upgrade"

    post 'login' => 'users#login'
    get 'user' => 'users#whoami'
  end

  get '*foo', :to => 'landing#index'
  root :to => 'landing#index'
end
