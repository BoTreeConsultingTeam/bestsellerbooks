class AddRatingToBookMeta < ActiveRecord::Migration
  def change
    add_column :book_meta, :rating, :float
  	remove_column :book_details, :rating
  end
end
