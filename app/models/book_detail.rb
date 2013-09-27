class BookDetail < ActiveRecord::Base
  attr_accessible :author, :images, :isbn, :title, :publisher,:language
  has_one :book_price, dependent: :destroy
  def self.create_or_find_book_details!(books)
    refresh_books_detail!(books)
	  books.each { |key,value|
	 		book_details = BookDetail.where(isbn: key).first_or_initialize(author: value[:author], images: value[:img], title: value[:title],language: value[:language],publisher: value[:publisher])
	 		if !book_details.persisted?
	 			book_details.save
	 			book_details.create_book_price(value[:price_list])
	 		end
	 	}
  end
  def self.show_books_details(page)
  	BookDetail.order('created_at').page(page).per(15)
  end
  def self.refresh_books_detail!(fresh_list_of_books_details)
    existing_books  = {}
    database_books_details_isbn = BookDetail.pluck(:isbn)
    database_books_details_isbn.each {|isbn|
      existing_books.merge!(isbn => isbn)
    }
    existing_books.each { |key, value| 
      unless fresh_list_of_books_details.has_key?(key)
        BookDetail.find_by_isbn(key).destroy
      else
        fresh_book_details = fresh_list_of_books_details.select{ |k,v| key == k}
          fresh_price_list = fresh_book_details[key][:price_list]
          old_price_list = BookDetail.find_by_isbn(key).book_price

          update_price!("crossword_price",fresh_price_list,old_price_list)
          update_price!("flipkart_price",fresh_price_list,old_price_list)
          update_price!("landmarkonthenet_price",fresh_price_list,old_price_list)
          update_price!("infibeam_price",fresh_price_list,old_price_list)    
          update_price!("amazon_price",fresh_price_list,old_price_list)   
      end
    }
  end
  def self.filter_books!(books_details,unique_books_details)
    book_hash = {}
    all_books = books_details.inject({}) { |hash,value|
        hash.merge!(value)
      }
    if !unique_books_details.empty?
      unique_books_details.each { |key,value|
        all_books.each { |k,v|
          if key == k
            unique_books_details[key][:price_list].merge!(v[:price_list])
            book_hash.merge!(unique_books_details.select {|key,value| key == k})
          else
            book_hash.merge!({"#{k}" => v})
          end
        }
      }
      book_hash.merge!(unique_books_details)
      book_hash
    else
      book_hash.merge!(all_books)
    end
    book_hash
  end
  def self.update_price!(site_price,fresh_price_list,old_price_list)
    if old_price_list.nil? && !fresh_price_list.nil?
      old_price_list.update_attributes(site_price.to_sym => fresh_price_list[site_price.to_sym])
    elsif !old_price_list.nil? && !fresh_price_list.nil?
      unless fresh_price_list[site_price.to_sym] == old_price_list[site_price.to_sym]
        old_price_list.update_attributes(site_price.to_sym => fresh_price_list[site_price.to_sym])
      end
    end
  end
end