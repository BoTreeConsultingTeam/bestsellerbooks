class BookDetail < ActiveRecord::Base
  attr_accessible :rating,:author, :images, :isbn, :title, :publisher,:language,:description
  has_many :book_metas, dependent: :destroy
  has_many :book_category, through: :category_detail
  
  scope :find_book_with_id, lambda { |book_details_id| where(id: book_details_id) }
  scope :find_book_with_isbn,  lambda { |book_details_isbn| where(isbn: book_details_isbn) }
  scope :search_books_details,  lambda { |detail,page| where("author ilike '%#{detail}%' or isbn = '%#{detail}%' or title ilike '%#{detail}%' or publisher ilike '%#{detail}%' or language ilike '%#{detail}%'").order('title').page(page).per(12) }
  scope :books_by_category, lambda { |c,page| where("category ilike c").order('title').page(page).per(12) }
  scope :book_author, pluck([:author])
  scope :book_title, pluck([:title])

  def self.create_or_find_book_details!(books)
    refresh_books_detail!(books)
    books.each { |key,value|
      book_details = BookDetail.where(isbn: key).first_or_initialize(author: value[:author], images: value[:img], title: value[:title],language: value[:language],publisher: value[:publisher],description: value[:description])
      if !book_details.persisted?
        book_details.save
        value[:book_meta_data].each { |isbn_key,book_detail_value|
          book_detail_value.merge!({ site_id: isbn_key })
          book_details.book_metas.create(book_detail_value)
          category = BookCategory.where(category: value[:category])
          category.each{ |c|
            puts c[:id]
            puts c[:category]
            CategoryDetail.create(book_category_id: c[:id],book_detail_id: book_details[:id])
          }
        }
      end
    }
  end

  def self.avg_rating(book)
    all_rating = book.book_metas.pluck(:rating)
    all_rating.delete(nil)
    if all_rating.count != 0
      avg_rating = (all_rating.sum) / all_rating.count
      avg_rating
    end
  end

  def self.show_books_details(page)
  	BookDetail.order('title').page(page).per(12)
  end

  def self.refresh_books_detail!(fresh_list_of_books_details)
    existing_books  = {}
    database_books_details_isbn = BookDetail.pluck(:isbn)
    database_books_details_isbn.each { |isbn|
      existing_books.merge!(isbn => isbn)
    }
    existing_books.each { |key, value|
      if fresh_list_of_books_details.has_key?(key)
        fresh_price_list = fresh_list_of_books_details[key][:book_meta_data]
        book_details = BookDetail.find_book_with_isbn(key).first
        site_having_book = book_details.book_metas.pluck(:site_id)
        fresh_price_list.each { |id,meta|
          old_price_list = book_details.book_metas.site_id(id).first
          if !old_price_list.nil?
            old_price_list.update_attributes(price: meta[:price],discount: meta[:discount])
            site_having_book.delete(id.to_i)
          else
            meta.merge!({ site_id: id })
            book_details.book_metas.create(meta)   
          end
        }
        site_having_book.each { |site_id|
          book_meta = book_details.book_metas.site_id(site_id).first
          book_meta.destroy
        }
      else
        BookDetail.find_book_with_isbn(key).first.destroy
      end
    }
  end

  def self.filter_books!(books_details,unique_books_details)
    book_hash = {}
    all_books = books_details.inject({}) { |hash,value| hash.merge!(value) }
    if !unique_books_details.empty?
      unique_books_details.each { |key,value|
        all_books.each { |k,v|
          if key == k
            if unique_books_details[key][:category].nil? && !all_books[key][:category].nil?
              unique_books_details[key][:category] = all_books[key][:category]
            end
            if unique_books_details[key][:description].nil? && !all_books[key][:description].nil?
              unique_books_details[key][:description] = all_books[key][:description]
            end
            if !unique_books_details[key][:category].nil? && !all_books[key][:category].nil?
              unique_books_details[key][:category] = unique_books_details[key][:category].concat(all_books[key][:category]).uniq
            elsif unique_books_details[key][:category].nil? && !all_books[key][:category].nil?
              unique_books_details[key][:category] = all_books[key][:category]
            end
            unique_books_details[key][:book_meta_data].merge!(v[:book_meta_data])
            book_hash.merge!(unique_books_details.select { |isbn,meta| isbn == k })
          else
            book_hash.merge!({ "#{k}" => v })
          end
        }
      }  
      book_hash.merge!(unique_books_details)
    else
      book_hash.merge!(all_books)
    end
    book_hash
  end

  def self.book_price(book_detail)
    book_detail.book_metas.order('price')
  end

  def self.select_category
    book_category = BookDetail.pluck(:category).uniq
    book_category.compact
    book_category
  end

end