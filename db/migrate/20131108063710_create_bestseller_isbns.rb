class CreateBestsellerIsbns < ActiveRecord::Migration
  def change
    create_table :bestseller_isbns do |t|
      t.string :isbn

      t.timestamps
    end
  end
end
