Rails.application.routes.draw do
  resources :mailing_lists, only: :create

  get "/about", to: "site#about", as: :about
  root "site#index"
end
