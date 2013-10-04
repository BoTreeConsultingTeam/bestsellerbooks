class RenameBookDetailToBookDetails < ActiveRecord::Migration
  def up
  	rename_column :book_meta, :book_detail_id, :book_details_id
  end

  def down
  end
end
