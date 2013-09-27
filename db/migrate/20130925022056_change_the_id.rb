class ChangeTheId < ActiveRecord::Migration
  def up
  	remove_column :book_details, :book_prices_id
  	add_column :book_prices, :book_detail_id, :integer
  end

  def down
  end
end
