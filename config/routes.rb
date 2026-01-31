# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "site#index"
  resources :training_times, only: :index

  resources :mailing_lists, only: %i[index create]

  get "rss", to: "feeds#rss", defaults: { format: "xml" }

  resource :profile

  namespace :people do
    resources :search, only: :index
  end
  resources :people, only: :show
  resources :person_relationships, only: :create

  resources :posts, except: :destroy do
    resources :comments, module: :posts
  end
  resources :events, except: :destroy

  resources :time_trials, except: :destroy do
    resources :tt_times, only: :new, module: :time_trials
  end

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index show update] do
      post :impersonate, on: :member
      post :stop_impersonating, on: :collection
    end
    resources :people
    resources :events
    resources :results, only: %i[edit update]
    resources :posts
    resources :teams
    resources :memberships, only: %i[new create]
  end

  mount Thredded::Engine => "/forum"

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"
end
