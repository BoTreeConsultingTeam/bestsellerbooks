class BookPrice < ActiveRecord::Base
  attr_accessible :book_details_id, :crossword_price, :flipkart_price, :infibeam_price, :landmarkonthenet_price, :book_detail_id, :amazon_price
  belongs_to :book_detail
end
