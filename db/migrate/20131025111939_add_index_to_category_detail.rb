class AddIndexToCategoryDetail < ActiveRecord::Migration
  def change
  	add_index :book_meta, [:book_detail_id, :site_id], unique: true
  end
end