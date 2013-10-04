class RenameBookDetailsIdToBookDetailsId < ActiveRecord::Migration
  def up
  	rename_column :book_meta, :book_details_id, :book_detail_id
  end

  def down
  end
end
