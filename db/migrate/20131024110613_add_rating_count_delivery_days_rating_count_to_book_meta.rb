class AddRatingCountDeliveryDaysRatingCountToBookMeta < ActiveRecord::Migration
  def change
  	add_column :book_meta, :rating_count, :integer
  	add_column :book_meta, :delivery_days, :string
  	add_column :book_meta, :shipping_detail, :string
  end
end