class AddOccurrenceToBestsellerIsbn < ActiveRecord::Migration
  def change
  	add_column :bestseller_isbns, :occurrence, :integer
  end
end
