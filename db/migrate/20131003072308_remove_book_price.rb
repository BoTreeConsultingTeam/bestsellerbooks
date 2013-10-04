class RemoveBookPrice < ActiveRecord::Migration
  def up
  	drop_table :book_prices
  end

  def down
  end
end
