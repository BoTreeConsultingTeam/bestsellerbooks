class BookDetail < ActiveRecord::Base
  attr_accessible :rating,:author, :images, :isbn, :title, :publisher,:language,:description
  
  has_many :category_details, dependent: :destroy
  has_many :book_categorys, through: :category_details
  has_many :book_metas, dependent: :destroy
  
  scope :find_book_with_id, lambda { |book_details_id| where(id: book_details_id) }
  scope :find_book_with_isbn,  lambda { |book_details_isbn| where(isbn: book_details_isbn) }
  scope :search_books_details,  lambda { |detail, page| where("author ilike '%#{detail}%' or isbn = '%#{detail}%' or title ilike '%#{detail}%' or publisher ilike '%#{detail}%' or language ilike '%#{detail}%'").order('title').page(page).per(12) }
  scope :book_author, pluck([:author])
  scope :book_title, pluck([:title])

  def self.create_or_find_book_details!(books)
    refresh_books_detail!(books)
    books.each do |key, value|
      book_details = BookDetail.where(isbn: key).first_or_initialize(author: value[:author], images: value[:img], title: value[:title],language: value[:language],publisher: value[:publisher],description: value[:description])
      unless book_details.persisted?
        site_id = []
        book_details.save
        value[:book_meta_data].each do |site_key, book_detail_value|
          site_id << site_key.to_i
          book_detail_value.merge!(site_id: site_key)
          book_details.book_metas.create(book_detail_value)
          create_category_details(value[:category], book_details) if !value[:category].nil?
        end
        isbn = book_details[:isbn]
        book_data = find_book_meta(book_details, isbn, site_id)
        unless book_data.nil?
          create_book_meta(book_details, book_data)
        end
      end
    end
  end

  def self.create_book_meta(book_details, book_data)
      book_details.book_metas.create!(book_data)
  end
  
  def self.find_book_meta(book_details, isbn, site_id)
    all_site = Site.pluck(:id)
    remain_site = all_site - site_id
    site = Site.where(id: remain_site)
    # book_data = {}
    book_data = []
    site.each do |s|
      if s[:name] == "crossword"
        url = "http://www.crossword.in/books/search?q=" + isbn
        crossword = Utilities::Scrappers::Scrapper.create_new_crossword_scrapper(url)
        crossword.process_page
        crossword_data = crossword.book_details
        data = crossword_data[0]
        puts data
        puts isbn
        if !data.nil? && data.key?(isbn)
          meta = data[isbn.to_s][:book_meta_data][s[:id].to_s]
          meta.merge!("site_id" => s[:id])
          # book_data.merge!(s[:id] => meta)
          book_data << meta
        end
      elsif s[:name] == "flipkart"
        url = "http://www.flipkart.com/search?q=" + isbn
        flipkart_data = Utilities::Scrappers::FlipkartScrapper.process_isbn_page(url)
        puts flipkart_data
        puts isbn
        if !flipkart_data.empty? && !flipkart_data[:price].nil? && flipkart_data[:isbn] == isbn.to_s
          # book_data.merge!(s[:id] => { discount: flipkart_data[:discount], site_id: s[:id], price: flipkart_data[:price], rating: flipkart_data[:rating], book_detail_url: url })
          book_data << { discount: flipkart_data[:discount], site_id: s[:id], price: flipkart_data[:price], rating: flipkart_data[:rating], book_detail_url: url }
        end
      elsif s[:name] == "amazon" 
        url = "http://www.amazon.in/s/ref=nb_sb_noss?url=search-alias%3Dstripbooks&field-keywords=" + isbn + "&rh=n%3A976389031%2Ck%3A" + isbn
        amazon = Utilities::Scrappers::Scrapper.create_new_amazon_search_book_scrapper(url)
        unless amazon.nil?
          amazon.process_page
          amazon_data = amazon.book_details
          data = amazon_data[0]
          puts data
          puts isbn
          if data[:isbn] == isbn && !data[:price].nil?
            # book_data.merge!(s[:id] => { discount: data[:discount], site_id: s[:id], price: data[:price], rating: data[:rating], book_detail_url: data[:url] })
            book_data << { discount: data[:discount], site_id: s[:id], price: data[:price], rating: data[:rating], book_detail_url: data[:url] }
          end
        end
      elsif s[:name] == "landmarkonthenet"
        url = "http://www.landmarkonthenet.com/search/?q=" + isbn
        landmarkonthenet_data = Utilities::Scrappers::LandmarkScrapper.process_isbn_page(url)
        puts landmarkonthenet_data
        puts isbn
        if !landmarkonthenet_data.empty? && !landmarkonthenet_data[:price].nil? && landmarkonthenet_data[:isbn] == isbn.to_s
          # book_data.merge!(s[:id] => { site_id: s[:id], discount: landmarkonthenet_data[:discount], price: landmarkonthenet_data[:price], book_detail_url: url })
          book_data << { site_id: s[:id], discount: landmarkonthenet_data[:discount], price: landmarkonthenet_data[:price], book_detail_url: url }
        end
      end
    end
    book_data
  end

  def self.create_category_details(category_from_site, book_details)
    category_from_site.each do |category|
      sub_category = category.gsub(/\&/,"").split
      sub_category.each do |n|
        category = BookCategory.where("category_name ilike '%#{n.gsub(/'s/,'')}%'")
        book_details.book_categorys << category unless category.nil?
      end
    end
  end

  def self.avg_rating(book)
    all_rating = book.book_metas.pluck(:rating).compact
    avg_rating = !all_rating.empty? ? (all_rating.sum) / all_rating.count : nil
    avg_rating 
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
    existing_books.each do |isbn_key, value|
      if fresh_list_of_books_details.key?(isbn_key)
        book_meta_data = fresh_list_of_books_details[isbn_key][:book_meta_data]
        book_details = BookDetail.find_book_with_isbn(isbn_key).first
        # site_having_book = book_details.book_metas.pluck(:site_id)
        book_meta_data.each do |site_id_key, meta|
        # site_id = site_id_key
          old_price_list = book_details.book_metas.site_id(site_id_key).first
          if old_price_list.nil?
            meta.merge!(site_id: site_id_key)
            book_details.book_metas.create(meta)
          else
            old_price_list.update_attributes(price: meta[:price], discount: meta[:discount])
            # site_having_book.delete(id.to_i)
          end
        end
        # book_data = find_book_meta(book_details, isbn, site_id)
        # update_book_meta(book_details, book_data)
        # site_having_book.each { |site_id| book_details.book_metas.site_id(site_id).first.destroy }
        # unless fresh_list_of_books_details[key][:category].nil?
        #   create_category_details(fresh_list_of_books_details[key][:category], book_details)
        # end
      else
        BookDetail.find_book_with_isbn(isbn_key).first.destroy
      end
    end
  end

  # def update_book_meta(book_details, book_data)
    # book_data.each do |data|
    # book_meta_data = book_details.book_meta.where(site_id: data[:site_id])
    # book_meta_data.update_attributes(price: book_data[:price], rating: book_data[:rating], )
  # end

  def self.filter_books!(books_details, unique_books_details)
    book_hash = {}
    all_books = books_details.inject({}) { |hash, value| hash.merge!(value) }
    if unique_books_details.empty?
      book_hash.merge!(all_books)
    else
      all_books.each do |key, value|
        if unique_books_details.key?(key)
          unique_books_details[key][:description] = all_books[key][:description] if unique_books_details[key][:description].nil? && !all_books[key][:description].nil?
          unique_books_details[key][:category] =
            if !unique_books_details[key][:category].nil? && !all_books[key][:category].nil?
              unique_books_details[key][:category].concat(all_books[key][:category]).uniq
            elsif unique_books_details[key][:category].nil? && !all_books[key][:category].nil?
              all_books[key][:category]
            end
          unique_books_details[key][:book_meta_data].merge!(value[:book_meta_data])
          book_hash.merge!("#{key}" => unique_books_details.fetch(key))
        else
          book_hash.merge!("#{key}" => value)
        end
      end  
      book_hash.merge!(unique_books_details)
    end
    book_hash
  end

  def self.book_price(book_detail)
    book_detail.book_metas.order('price')
  end

  def self.auto_search_data
    search_data = BookDetail.pluck([:author]).uniq
    search_data << BookDetail.pluck([:title]).uniq
    search_data = search_data.join(',')
    search_data
  end

end