class BookCategory < ActiveRecord::Base
  attr_accessible :category_name
  
  has_many :category_details, dependent: :destroy
  has_many :book_details, through: :category_details
  
  scope :book_category, pluck([:category_name])

  def self.books_category(id, page)
    book_data = BookCategory.find(id).book_details.order('title').page(page).per(12).uniq
    book_data
  end
  
end
