class ChangeRatingDataTypeToFloat < ActiveRecord::Migration
  def up
  	remove_column :book_details, :rating
  	add_column :book_details, :rating, :float
  end

  def down
  end
end
