class CreateBookMeta < ActiveRecord::Migration
  def change
    create_table :book_meta do |t|
      t.integer :book_detail_id
      t.integer :site_id
      t.string :data_type
      t.string :data

      t.timestamps
    end
  end
end
