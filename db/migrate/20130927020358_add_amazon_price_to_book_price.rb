class AddAmazonPriceToBookPrice < ActiveRecord::Migration
  def change
  	add_column :book_prices, :amazon_price, :integer
  end
end
