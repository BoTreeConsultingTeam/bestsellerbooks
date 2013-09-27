class AddToBookDetails < ActiveRecord::Migration
  def up
  	add_column :book_details, :publisher, :string
  	add_column :book_details, :language, :string
  end

  def down
  end
end
