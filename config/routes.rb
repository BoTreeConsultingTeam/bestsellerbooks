Bestsellerbooks::Application.routes.draw do

  root :to => 'scrappers#show_latest_books'
  
  devise_for :users, path_prefix: :admin, :controllers => { :registrations => "admin" } do
    get "/register", :to => "admin#new"
  end

  resources :admin, only: :index

  resources :users do
    get 'sign_out', to: 'scrappers#show_latest_books'
  end

  get 'books/manually_add_books', to: 'scrappers#manually_add_books', as: 'manually_add_books'
  get 'books/price_details', to: 'scrappers#price_details', as: 'price_details'
  get 'books/refresh_details', to: 'scrappers#refresh_details', as: 'refresh_details'
  get 'books/show',to: 'scrappers#show', as: 'show'
  get 'books/show_books_by_category', to: 'scrappers#show_books_by_category', as: 'show_books_by_category'
  get 'books/find_book_price', to: 'scrappers#find_book_price'

  scope '/admin/bestsellerbooks' do
    get 'manually_add_isbn/search', to: 'manually_add_isbn#search', as: 'manually_add_isbn_search'
    get 'manually_add_isbn/show', to: 'manually_add_isbn#show', as: 'manually_add_isbn_show'
    post 'manually_add_isbn/create', to: 'manually_add_isbn#create', as: 'manually_add_isbn_create'
    post 'manually_add_isbn/update', to: 'manually_add_isbn#update', as: 'manually_add_isbn_update'
    resources :manually_add_isbn do
      get 'manually_add_isbn/:search', to: 'manually_add_isbn#destroy', as: 'destroy'
    end
  end

  
end