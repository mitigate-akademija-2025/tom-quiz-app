Rails.application.routes.draw do
  get "quiz/index"
  get "quiz/show"
  get "quiz/new"
  get "quiz/create"
  get "quiz/edit"
  get "quiz/update"
  get "quiz/destroy"
  resources :quiz
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "quiz#index"





  # Test tailwind setup
  get 'test', to: 'test#index'

end
