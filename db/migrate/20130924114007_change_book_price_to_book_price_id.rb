class ChangeBookPriceToBookPriceId < ActiveRecord::Migration
  def up
  	rename_column :book_details, :book_prices, :book_prices_id
  end

  def down
  end
end
