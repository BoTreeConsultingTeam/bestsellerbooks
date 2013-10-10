class AddRatingToBookDetail < ActiveRecord::Migration
  def change
  	add_column :book_details, :rating, :float
  	add_column :book_details, :category, :string
  end
end