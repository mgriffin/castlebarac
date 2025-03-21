# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "site#index"

  resources :mailing_lists, only: %i[index create]

  get "rss", to: "feeds#rss", defaults: { format: "xml" }

  resource :profile

  resources :posts, only: %i[index show] do
    resources :comments, module: :posts
  end
  resources :events, only: %i[index show]

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index update]
    resources :people, only: %i[index new edit update]
    resources :teams
    resources :posts
    resources :events
  end

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"
end
