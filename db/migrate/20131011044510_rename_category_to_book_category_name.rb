class RenameCategoryToBookCategoryName < ActiveRecord::Migration
  def up
  	rename_column :book_categories, :category, :category_name
  	drop_table :book_detail_book_categories
  end

  def down
  end
end
