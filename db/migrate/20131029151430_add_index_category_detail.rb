class AddIndexCategoryDetail < ActiveRecord::Migration
  def up
  	add_index :category_details, [:book_category_id, :book_detail_id], unique: true
  	add_index :category_details, :book_category_id
  	add_index :category_details, :book_detail_id
  end

  def down
  end
end