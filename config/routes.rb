require "sidekiq/web"
require_dependency "admin_constraint"

USERNAME_ROUTE_FORMAT = /[A-Za-z0-9\_]+/ unless defined? USERNAME_ROUTE_FORMAT

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  else
    mount Sidekiq::Web => "/sidekiq", constraints: AdminConstraint.new
  end

  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.pebblescape+json; version=1"}) do
    resources :apps do
      resources :builds
    end
    resources :users

    get 'auth' => 'users#auth'
  end

  resources :static
  get "login" => "static#show", id: "login"

  resources :session, id: USERNAME_ROUTE_FORMAT, only: [:create, :destroy, :become] do
    collection do
      post "forgot_password"
    end
  end

  get "session/current" => "session#current"
  get "session/csrf" => "session#csrf"

  root "apps#index"
end
