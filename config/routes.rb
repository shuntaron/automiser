Rails.application.routes.draw do
  root to: "time_cards#index"
  resources :time_cards do
    collection do
      post  :scrape
      get   :bulk_edit
      patch :bulk_update
    end
  end
end
