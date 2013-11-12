class BestsellerIsbn < ActiveRecord::Base
  attr_accessible :isbn, :title
  validates :isbn, length: { is: 13 }
  validates :title, :isbn, presence: true
  
  def self.find_book_isbn(page)
  	BestsellerIsbn.order("created_at DESC").page(page).per(10)
  end

  def self.create_book_isbn(isbn, title)
  	BestsellerIsbn.where(isbn: isbn).first_or_create(title: title)
  end

  def self.destroy_book_isbn(book_id)
  	BestsellerIsbn.find(book_id).destroy
  end

  def self.find_book(search_detail, page)
    BestsellerIsbn.where("isbn ilike '%#{search_detail}%' or title ilike '%#{search_detail}%'").order("created_at DESC").page(page).per(10)
  end
end