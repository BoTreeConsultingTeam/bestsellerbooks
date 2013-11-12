class AddTitleToBestsellerIsbn < ActiveRecord::Migration
  def change
  	add_column :bestseller_isbns, :title, :string
  end
end
