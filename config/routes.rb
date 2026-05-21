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

namespace :api do
    resources :issues do
      # Rutes de col·lecció (afecten a totes les issues)
      collection do
        post :bulk
      end

      # Rutes de membre (afecten a una issue concreta, ex: /issues/1/watchers)
      member do
        post :watchers, to: "issues#add_watcher"
        delete "watchers/:watcher_id", to: "issues#remove_watcher"
        post :attachments, to: "issues#add_attachment"
        delete "attachments/:attachment_id", to: "issues#remove_attachment"
      end

      # Rutes niades per als comentaris
      resources :comments, only: [ :create, :update, :destroy ]
    end

    resources :issue_types
    resources :severities
    resources :statuses
    resources :priorities
    resources :tags

    resources :users, only: [ :show, :update ] do
      member do
        get :assigned_issues
        get :watched_issues
        get :comments
      end
    end
  end
  root "issues#index"
end
