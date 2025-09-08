Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "confirm", to: "users#confirm", as: :confirm
  get "login", to: "sessions#new", as: :login
  get "/auth/:provider/callback", to: "sessions#omniauth"
  get "/auth/failure", to: "sessions#failure"

  resources :users, only: [ :new, :create, :destroy ] do
    member do
      get :profile
      get :edit_email
      patch :update_email
      get :edit_password
      patch :update_password
      get "edit_api_key/:api_type", to: "users#edit_api_key", as: :edit_api_key
      patch "update_api_key/:api_type", to: "users#update_api_key", as: :update_api_key
      delete "destroy_api_key/:api_type", to: "users#destroy_api_key", as: :destroy_api_key
    end

    collection do
      get :resend_confirmation
      post :send_confirmation
    end
  end

  resources :quizzes do
    resources :questions do
      resources :answers, except: [ :index, :show ]
    end

    member do
      get "start"
      get "take"
      post "answer"
      get "results"
    end

    collection do
      get "generate"
      post "create_from_ai"
    end
  end

  root "quizzes#index"
  get "test", to: "test#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
