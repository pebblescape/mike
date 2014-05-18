require 'sidekiq/web'
require_dependency "scheduler/web"
# require_dependency 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'#, constraints: AdminConstraint.new
  
  root 'home#index'
end
