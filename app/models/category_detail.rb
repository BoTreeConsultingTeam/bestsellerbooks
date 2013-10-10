class CategoryDetail < ActiveRecord::Base
  attr_accessible :book_category_id, :book_detail_id
  belongs_to :book_category
  belongs_to :book_detail
end
