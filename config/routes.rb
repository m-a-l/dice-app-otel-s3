Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dice#index"
  get '/fake_worker', to: 'dice#fake_worker'
end
