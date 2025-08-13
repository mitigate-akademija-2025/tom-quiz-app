Rails.application.routes.draw do
  resources :quizzes do
    resources :questions do
      resources :answers, except: [ :index, :show ]
    end
  end

  get "/quizzes/:id/start", to: "quizzes#start", as: "start_quiz"
  get "/quizzes/:id/take", to: "quizzes#take", as: "take_quiz"
  post "/quizzes/:id/answer", to: "quizzes#answer", as: "answer_quiz"
  get "/quizzes/:id/results", to: "quizzes#results", as: "results_quiz"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "quizzes#index"

  # Test tailwind setup
  get "test", to: "test#index"
end
