# frozen_string_literal: true

Rails.application.routes.draw do
  resources :mailing_lists, only: :create

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  get "/about", to: "site#about", as: :about

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  root "site#index"
end
