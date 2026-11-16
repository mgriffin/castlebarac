# frozen_string_literal: true

Rails.application.routes.draw do
  # Competition pages don't exist unless the comp-entries flag is on
  competition_entries = ->(request) { Castlebarac.competition_entries?(request.env["warden"].user) }

  devise_for :users
  root "site#index"
  resources :training_times, only: :index
  namespace :training do
    resources :little_athletics, only: :index
  end

  resources :mailing_lists, only: :index

  get "rss", to: "feeds#rss", defaults: { format: "xml" }

  resource :profile, only: %i[show new create edit update] do
    resource :claim, only: :destroy, module: :profiles
    resources :child_claims, only: %i[new create destroy], module: :profiles
  end

  namespace :people do
    resources :search, only: :index
  end
  resources :people, only: :show
  resource :impersonation, only: :destroy

  resources :posts, except: :destroy do
    resources :comments, only: :create, module: :posts
  end
  resources :events, except: :destroy

  constraints competition_entries do
    resources :competitions, only: :show do
      scope module: :competitions do
        resource :entry, only: :show do
          resource :payment, only: %i[show create]
          resources :athletes, only: %i[new create show update destroy] do
            resource :details, only: :update
          end
        end
      end
    end
  end

  resources :time_trials, only: %i[index show new create update] do
    resources :tt_times, only: :new, module: :time_trials
  end

  resources :coaches, only: :index
  namespace :coaches do
    resources :posts, only: %i[show new create]
  end

  namespace :admin do
    root to: "admin#index"

    resources :users, only: %i[index show] do
      post :impersonate, on: :member
      resource :admin_membership, only: %i[create destroy], module: :users
    end
    resources :people, only: %i[index new create edit update] do
      resources :relationships, only: :create, module: :people
      resource :account, only: %i[create destroy], module: :people
    end
    resources :child_claims, only: :index do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :person_claims, only: :index do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :events, except: :destroy do
      resources :unlinked_results, only: %i[index create]
    end
    resources :results, only: %i[edit update]
    resources :result_imports, only: %i[new create] do
      get :preview, on: :collection
    end
    resources :posts, only: %i[index new create edit update]
    resources :teams, only: %i[index show new create] do
      resources :memberships, only: %i[create destroy], module: :teams
    end
    constraints competition_entries do
      resources :competitions do
        scope module: :competitions do
          resource :opening, only: %i[create destroy]
          resources :entries, only: :index
          resources :entry_lines, only: :destroy
        end
      end
    end
  end

  # Not behind the comp-entries flag, so checkouts started while it was on
  # are still recorded if it's turned off
  post "stripe/webhooks", to: "stripe_webhooks#create"

  get "404", to: "errors#not_found"
  get "500", to: "errors#internal_error"

  authenticate :user, ->(user) { user.admin? } do
    mount Flipper::UI.app(Flipper) => "/flipper", as: :flipper
  end
end
