class AddAvgRatingAndOccurrenceToBookDetail < ActiveRecord::Migration
  def change
  	add_column :book_details, :average_rating, :integer
  	add_column :book_details, :occurrence, :integer
  end
end
