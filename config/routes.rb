Rails.application.routes.draw do
  get "profiles/show"
  get "profiles/edit"
  get "profiles/update"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  get "activities/index"
  resources :tags
  resources :severities
  resources :issue_types
  resources :priorities
  resources :statuses
  resources :issues do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end
  resources :users
  resources :profiles, only: [ :show, :edit, :update ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "issues#index"
end
