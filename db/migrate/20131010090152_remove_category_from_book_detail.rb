class RemoveCategoryFromBookDetail < ActiveRecord::Migration
  def up
  	remove_column :book_details, :category
  end

  def down
  end
end
