# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "site#index"
  resources :training_times, only: :index
  namespace :training do
    resources :little_athletics, only: :index
  end

  resources :mailing_lists, only: %i[index create]

  get "rss", to: "feeds#rss", defaults: { format: "xml" }

  resource :profile

  namespace :people do
    resources :search, only: :index
  end
  resources :people, only: :show

  resources :posts, except: :destroy do
    resources :comments, module: :posts
  end
  resources :events, except: :destroy

  resources :time_trials, except: :destroy do
    resources :tt_times, only: :new, module: :time_trials
  end

  resources :coaches, only: :index
  namespace :coaches do
    resources :posts
  end

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index show] do
      post :impersonate, on: :member
      post :stop_impersonating, on: :collection
      resource :admin_membership, only: %i[create destroy], module: :users
    end
    resources :people do
      resources :relationships, only: :create, module: :people
    end
    resources :events do
      resources :unlinked_results, only: %i[index create]
    end
    resources :results, only: %i[edit update]
    resources :result_imports, only: %i[new create] do
      get :preview, on: :collection
    end
    resources :posts
    resources :teams do
      resources :memberships, only: %i[create destroy], module: :teams
    end
  end

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"

  authenticate :user, ->(user) { user.admin? } do
    mount Flipper::UI.app(Flipper) => "/flipper", as: :flipper
  end
end
