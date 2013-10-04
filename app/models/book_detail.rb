class BookDetail < ActiveRecord::Base
  attr_accessible :author, :images, :isbn, :title, :publisher,:language
  has_many :book_metas, dependent: :destroy
  def self.create_or_find_book_details!(books)
    refresh_books_detail!(books)    
    books.each { |key,value|
      book_details = BookDetail.where(isbn: key).first_or_initialize(author: value[:author], images: value[:img], title: value[:title],language: value[:language],publisher: value[:publisher])
      if !book_details.persisted?
        book_details.save
        value[:book_meta_data].each { |k,v|
          v.merge!({site_id: k})
          book_details.book_metas.create(v)
        }
      end
    }
  end
  def self.find_book(id)
    BookDetail.find_by_id(id)
  end
  def self.search_books_details(detail,page)
    BookDetail.where("author ilike '%#{detail}%' or isbn = '%#{detail}%' or title ilike '%#{detail}%' or publisher ilike '%#{detail}%' or language ilike '%#{detail}%'").order('title').page(page).per(12)
  end
  def self.show_books_details(page)
  	BookDetail.order('title').page(page).per(12)
  end
  def self.refresh_books_detail!(fresh_list_of_books_details)
    existing_books  = {}
    database_books_details_isbn = BookDetail.pluck(:isbn)
    database_books_details_isbn.each {|isbn|
      existing_books.merge!(isbn => isbn)
    }
    existing_books.each { |key, value| 
      if fresh_list_of_books_details.has_key?(key)
        fresh_book_details = fresh_list_of_books_details.select{ |k,_| key == k}
        fresh_price_list = fresh_book_details[key][:book_meta_data]
        book_details = BookDetail.find_by_isbn(key)
        site_having_book = book_details.book_metas.pluck(:site_id)
        fresh_price_list.each {|id,meta|
          old_price_list = book_details.book_metas.find_by_site_id(id)
          if !old_price_list.nil?
            old_price_list.update_attributes(price: meta[:price],discount: meta[:discount])
            site_having_book.delete(id.to_i)
          else
            meta.merge!({site_id: id})
            book_details.book_metas.create(meta)   
          end
        }
        site_having_book.each {|site_id|
          book_meta = book_details.book_metas.find_by_site_id(site_id)
          book_meta.destroy
        }
      else
        BookDetail.find_by_isbn(key).destroy
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
            unique_books_details[key][:book_meta_data].merge!(v[:book_meta_data])
            book_hash.merge!(unique_books_details.select {|isbn,_| isbn == k})
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
  def self.book_price(book_detail)
    book_detail.book_metas.order('price')
  end
end