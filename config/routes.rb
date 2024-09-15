# frozen_string_literal: true

Rails.application.routes.draw do
  root "site#index"

  resources :mailing_lists, only: %i[index create]

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  get "/about", to: "site#about", as: :about

  get "/news/:year/:month/:id",
      to: "posts#show",
      as: :post_permalink,
      year: /20\d{2}/,
      month: /[01]?\d/

  namespace :admin do
    root to: "admin#index"

    resources :users, only: :index
    resources :posts
    resources :events
  end

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"
end
