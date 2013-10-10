class BookCategory < ActiveRecord::Base
  attr_accessible :category
  has_many :book_detail, through: :category_detail
  scope :book_category, pluck([:category])
end
