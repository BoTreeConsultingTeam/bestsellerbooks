class ChangeIsbnToString < ActiveRecord::Migration
  def up
  	change_column :book_details, :isbn, :string
  end

  def down
  end
end
