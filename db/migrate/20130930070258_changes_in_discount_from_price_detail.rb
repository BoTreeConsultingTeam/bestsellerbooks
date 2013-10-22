class ChangesInDiscountFromPriceDetail < ActiveRecord::Migration
  def up
  	add_column :book_prices, :crossword_price_discount, :integer
  	add_column :book_prices, :flipkart_price_discount, :integer
  	add_column :book_prices, :landmarkonthenet_price_discount, :integer
  	add_column :book_prices, :infibeam_price_discount, :integer
  	add_column :book_prices, :amazon_price_discount, :integer
  end

  def down
  end
end
