Rails.application.routes.draw do
  root "homes#index"

  resources :transactions do
    get "edit_return_book"
    put "update_return_book"
  end

  resources :books
  resources :patrons do
    resources :transactions
  end
end
