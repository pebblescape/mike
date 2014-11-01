require "sidekiq/web"
require_dependency "admin_constraint"

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  else
    mount Sidekiq::Web => "/sidekiq", constraints: AdminConstraint.new
  end
  
  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.pebblescape+json; version=1"}) do
    resources :apps
    resources :users
    
    get 'auth' => 'users#auth'
  end
  
  resources :static
  post "login" => "static#enter"
  
  get "login" => "static#show", id: "login"
  root "static#root"
end
