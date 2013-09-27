class CreateBookPrices < ActiveRecord::Migration
  def change
    create_table :book_prices do |t|
      t.integer :book_details_id
      t.integer :crossword_price
      t.integer :flipkart_price
      t.integer :landmarkonthenet_price
      t.integer :infibeam_price

      t.timestamps
    end
  end
end
