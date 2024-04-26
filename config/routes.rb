Rails.application.routes.draw do
  resources :mailing_lists, only: :create

  root "site#index"
end
