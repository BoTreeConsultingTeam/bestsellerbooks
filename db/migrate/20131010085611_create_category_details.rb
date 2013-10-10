class CreateCategoryDetails < ActiveRecord::Migration
  def change
    create_table :category_details do |t|
      t.integer :book_category_id
      t.integer :book_detail_id

      t.timestamps
    end
  end
end
