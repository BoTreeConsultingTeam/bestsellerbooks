class ChangesInBookMeta < ActiveRecord::Migration
  def up
  	remove_column :book_meta, :data_type
  	remove_column :book_meta, :data
  	add_column :book_meta, :price, :integer
  	add_column :book_meta, :discount, :integer
  	add_column :book_meta, :book_detail_url, :string
  end

  def down
  end
end
