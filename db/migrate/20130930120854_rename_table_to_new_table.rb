class RenameTableToNewTable < ActiveRecord::Migration
  def up
  	rename_table :book_detail, :book_details
  	rename_table :book_price, :book_prices
  end

  def down
  end
end
