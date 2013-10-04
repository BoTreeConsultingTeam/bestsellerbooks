Bestsellerbooks::Application.routes.draw do
  
  root :to => 'scrappers#show_latest_books'
  get "scrappers/show_latest_books"
  get 'scrappers/price_details', to: "scrappers#price_details", as: 'price_details'
  get 'scrappers/refresh_details', to: 'scrappers#refresh_details', as: 'refresh_details'
  get "scrappers/show", to: "scrappers#show", as: "show"
  resources 'scrappers' do
   get :autocomplete_book_detail_title, :on => :collection
  end
  # get 'scrappers/autocomplete_book_detail_title'
 
end
