Rails.application.routes.draw do
  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.pebblescape+json; version=1"}) do
    resources :apps
    resources :users
    
    get 'auth' => 'users#auth'
  end
  
  get "login" => "static#show", id: "login"
end
