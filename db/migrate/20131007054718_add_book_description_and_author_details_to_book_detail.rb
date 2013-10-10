class AddBookDescriptionAndAuthorDetailsToBookDetail < ActiveRecord::Migration
  def change
  	add_column :book_details, :book_description, :text
  	add_column :book_details, :author_detail, :text
  end
end
