class BookCategory < ActiveRecord::Base
  default_scope order(:category_name)
  attr_accessible :category_name
  
  has_many :category_details, dependent: :destroy
  has_many :book_details, through: :category_details
  
  scope :book_category, pluck([:category_name])

  def self.books_category(id, page)
    BookCategory.find(id).book_details.order('occurrence DESC', 'average_rating DESC').page(page).per(12).uniq
  end
  
end
