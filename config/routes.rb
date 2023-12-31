Rails.application.routes.draw do
  root to: "time_cards#index"
  resources :time_cards do
    collection do
      post  :scrape
      get   :bulk_edit
      patch :bulk_update
      post  :sync_data
      delete :bulk_delete
    end
  end
end
