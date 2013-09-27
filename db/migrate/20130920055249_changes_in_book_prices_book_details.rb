class ChangesInBookPricesBookDetails < ActiveRecord::Migration
  def up
  	remove_column :book_prices, :book_details_id
  	add_column :book_details, :book_prices, :integer
  end

  def down
  end
end
