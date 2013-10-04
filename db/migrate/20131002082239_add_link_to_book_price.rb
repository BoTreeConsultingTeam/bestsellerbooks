class AddLinkToBookPrice < ActiveRecord::Migration
  def change
  	add_column :book_prices, :crossword_buy_link, :string
  	add_column :book_prices, :flipkart_buy_link, :string
  	add_column :book_prices, :landmarkonthenet_buy_link, :string
  	add_column :book_prices, :infibeam_buy_link, :string
  	add_column :book_prices, :amazon_buy_link, :string
  end
end
