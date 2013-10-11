class BookCategory < ActiveRecord::Base
  attr_accessible :category_name
  
  has_many :category_details, dependent: :destroy
  has_many :book_details, through: :category_details
  
  scope :book_category, pluck([:category_name])
end
