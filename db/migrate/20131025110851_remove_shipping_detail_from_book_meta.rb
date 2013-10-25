class RemoveShippingDetailFromBookMeta < ActiveRecord::Migration
  def up
  	remove_column :book_meta, :shipping_detail
  end

  def down
  end
end
