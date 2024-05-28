# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {sign_in: "login", sign_out: "logout"}
  resources :mailing_lists, only: :create
  resources :users, only: [ :index, :update ]

  get "/about", to: "site#about", as: :about

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  root "site#index"
end
