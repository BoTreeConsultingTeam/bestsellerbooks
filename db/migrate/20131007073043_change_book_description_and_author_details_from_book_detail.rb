class ChangeBookDescriptionAndAuthorDetailsFromBookDetail < ActiveRecord::Migration
  def up
  	rename_column :book_details, :book_description, :description
  	remove_column :book_details, :author_detail
  end

  def down
  end
end