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
    resources :comments, shallow: true, only: [ :create, :edit, :update, :destroy ]
    collection do
      get :bulk
      post :create_bulk
    end
  end
  resources :users
  resources :profiles, only: [ :show, :edit, :update, :destroy ]

  # --- RUTES DE L'API (Tasca US90 i US92 amb rutes separades) ---
  namespace :api do
    resources :issues do
      member do
        # Rutes extres per a la issue concreta
        post :watchers, to: "issues#add_watcher"
        delete "watchers/:watcher_id", to: "issues#remove_watcher"
        post :attachments, to: "issues#add_attachment"
        delete "attachments/:attachment_id", to: "issues#remove_attachment"
      end
    end

    resources :issue_types
    resources :severities

    resources :users, only: [ :show, :update ] do
      member do
        get :assigned_issues
        get :watched_issues
        get :comments
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "issues#index"
end
