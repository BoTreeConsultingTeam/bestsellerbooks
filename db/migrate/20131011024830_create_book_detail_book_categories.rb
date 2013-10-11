class CreateBookDetailBookCategories < ActiveRecord::Migration
  def change
    create_table :book_detail_book_categories do |t|
	  t.belongs_to :book_detail
      t.belongs_to :book_category
      t.timestamps
    end
  end
end