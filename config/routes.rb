Rails.application.routes.draw do
  resource :session
  resources :users, only: [ :new, :create, :edit, :update ]
  resources :passwords, param: :token
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
