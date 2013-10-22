Bestsellerbooks::Application.routes.draw do
  
  root :to => 'scrappers#show_latest_books'
  get "books/show_latest_books"
  get 'books/price_details', to: "scrappers#price_details", as: 'price_details'
  get 'books/refresh_details', to: 'scrappers#refresh_details', as: 'refresh_details'
  get "books/show", to: "scrappers#show", to: 'scrappers#show', as: "show"
  get "books/show_books_by_category", to: 'scrappers#show_books_by_category', as: "show_books_by_category"
  get "books/find_book_price", to: 'scrappers#find_book_price'
  # resources 'scrappers' do
  #  get :autocomplete_book_detail_title, :on => :collection
  # end
end
