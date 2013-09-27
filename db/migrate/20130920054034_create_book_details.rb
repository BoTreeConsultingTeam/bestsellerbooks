class CreateBookDetails < ActiveRecord::Migration
  def change
    create_table :book_details do |t|
      t.text :images
      t.string :author
      t.string :title
      t.integer :isbn
      t.timestamps
    end
  end
end
