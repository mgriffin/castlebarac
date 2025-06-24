# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "site#index"

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

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index update]
    resources :people
    resources :events
    resources :results, only: %i[edit update]
    resources :posts
    resources :teams
    resources :memberships, only: %i[new create]
  end

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"
end
