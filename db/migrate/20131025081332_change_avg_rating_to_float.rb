class ChangeAvgRatingToFloat < ActiveRecord::Migration
  def up
  	change_column :book_details, :average_rating, :float
  end

  def down
  end
end
