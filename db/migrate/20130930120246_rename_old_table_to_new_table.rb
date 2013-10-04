class RenameOldTableToNewTable < ActiveRecord::Migration
  def up
  	rename_table :book_details, :book_detail
  	rename_table :book_prices, :book_price

  end

  def down
  end
end
