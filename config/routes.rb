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

  resources :posts, only: %i[index show] do
    resources :comments, module: :posts
  end
  resources :events, only: %i[index show]

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index update]
    resources :people
    resources :events
    resources :posts
    resources :teams
    resources :memberships, only: %i[new create]
  end

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"
end
