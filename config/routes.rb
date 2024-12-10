# frozen_string_literal: true

Rails.application.routes.draw do
  root "site#index"

  resources :mailing_lists, only: %i[index create]

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy", as: :logout

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  get "rss", to: "feeds#rss", defaults: { format: "xml" }

  resource :profile

  get "about", to: "site#about", as: :about

  resources :posts, only: :show

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
