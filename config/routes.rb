Rails.application.routes.draw do
  root to: "time_cards#index"
  resources :time_cards
end
