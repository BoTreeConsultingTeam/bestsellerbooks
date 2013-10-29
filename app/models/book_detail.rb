class BookDetail < ActiveRecord::Base
  attr_accessible :rating, :author, :images, :isbn, :title, :publisher, :language, :description, :occurrence, :average_rating
  validates :isbn, presence: true

  has_many :category_details, dependent: :destroy
  has_many :book_categories, through: :category_details
  has_many :book_metas, dependent: :destroy
  
  scope :find_book_with_id, lambda { |book_details_id| where(id: book_details_id) }
  scope :find_book_with_isbn,  lambda { |book_details_isbn| where(isbn: book_details_isbn) }
  scope :search_books_details,  lambda { |detail, page| where("author ilike '%#{detail}%' or isbn ilike '%#{detail}%' or title ilike '%#{detail}%' or publisher ilike '%#{detail}%' or language ilike '%#{detail}%'").order('occurrence DESC', 'average_rating DESC').page(page).per(12) }
  scope :book_author, pluck([:author])
  scope :book_title, pluck([:title])

  def self.create_or_find_book_details!(books)
    refresh_books_detail!(books)
    books.each do |key, value|
      begin
        meta = self.calculate_rating_avg(books[key][:book_meta_data])
        book_details = self.where(isbn: key).first_or_initialize(author: value[:author], images: value[:img], title: value[:title], language: value[:language], publisher: value[:publisher], description: value[:description], average_rating: meta[0], occurrence: meta[1])
        unless book_details.persisted? 
          site_id = []
          book_details.save
          book_meta_data = []
          value[:book_meta_data].each do |site_key, book_detail_value|
            site_id << site_key.to_i
            book_detail_value.merge!(site_id: site_key)
            book_meta_data << book_detail_value
            create_category_details(value[:category], book_details) if !value[:category].nil?
          end
          isbn = book_details[:isbn]
          create_book_meta(book_details, book_meta_data)
        end
      rescue Exception => e
        logger.debug "In...#{key}...book isbn...error occured"
        logger.debug "Book data of...#{key}...#{value}"
      end
    end
  end

  def self.update_average_rating(book_data, book_details)
    unless book_data.nil?
      hash = {}
      book_data.each do |data|
        hash.merge!("#{data[:site_id]}" => data)
      end
      meta = BookDetail.calculate_rating_avg(hash)
      average_rating = book_details[:average_rating]
      if !meta[0].nil? && average_rating.nil?
        book_details.update_attributes(average_rating: meta[0])
      elsif !average_rating.nil? && !meta[0].nil?
        average_rating = (average_rating.to_f + meta[0].to_f) / 2
        book_details.update_attributes(average_rating: average_rating)
      end
    end
  end

  def self.calculate_rating_avg(book_meta_data)
    site_id = Site::ALL_SITE_IDS
    rating = []
    rating_count = []
    site_id.each do |site|
      if book_meta_data.key?("#{site}")
        data = book_meta_data["#{site}"]
        rating << (data[:rating].to_f * data[:rating_count].to_i)
        rating_count << data[:rating_count].to_i
      end
    end
    begin
      rating.delete(0)
      avg = (rating.compact).sum / (rating_count.compact).sum
    rescue Exception => e
      avg = nil
    end
    meta = [avg, rating_count.count]
    meta
  end
  
  def self.create_book_meta(book_details, book_data)
    book_data.each do |meta|
      begin
        book_details.book_metas.create!(rating_count: meta[:rating_count], delivery_days: meta[:delivery_days], site_id: meta[:site_id], book_detail_url: meta[:book_detail_url], price: meta[:price], discount: meta[:discount], rating: meta[:rating])
      rescue Exception => e
        logger.debug "book id...#{book_details.id}...isbn...#{book_details.isbn}"
        logger.debug "Error occured while creating book meta of ...#{meta}"
      end
    end
  end
  
  def self.find_book_meta(book_details, isbn, remain_site)
    book_data = []
    Site.where(id: remain_site).each do |site|
      logger.debug "Processing #{site[:name]} for prices....."
      case site[:name]
        when "crossword"
          url = "http://www.crossword.in/books/search?q=" + isbn
          crossword = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:crossword, url)
          book_data = self.process_search_book_data(crossword, isbn, site[:id], book_data, url, book_details)
        when "flipkart"
          url = "http://www.flipkart.com/search?q=" + isbn
          flipkart = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:flipkart, url)
          book_data = self.process_search_book_data(flipkart, isbn, site[:id], book_data, url, book_details)
        when "amazon"
          url = "http://www.amazon.in/s/ref=nb_sb_noss?url=search-alias%3Dstripbooks&field-keywords=" + isbn + "&rh=n%3A976389031%2Ck%3A" + isbn
          amazon = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:amazon, url)
          book_data = self.process_search_book_data(amazon, isbn, site[:id], book_data, url, book_details)
        when "landmarkonthenet"
          url = "http://www.landmarkonthenet.com/search/?q=" + isbn
          landmarkonthenet = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:landmark, url)
          book_data = self.process_search_book_data(landmarkonthenet, isbn, site[:id], book_data, url, book_details)
        when "uread"
          url = "http://www.uread.com/search-books/" + isbn
          uread = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:uread, url)
          book_data = self.process_search_book_data(uread, isbn, site[:id], book_data, url, book_details)
        when "homeshop18"
          url = "http://www.homeshop18.com/search:" + isbn
          uread = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:homeshop18, url)
          book_data = self.process_search_book_data(uread, isbn, site[:id], book_data, url, book_details)
        when "indiatimes"
          url = "http://shopping.indiatimes.com/mtkeywordsearch?SEARCH_STRING=" + isbn + "&catalog=10011"
          uread = Utilities::Scrappers::Scrapper.get_search_page_scrapper(:indiatimes, url)
          book_data = self.process_search_book_data(uread, isbn, site[:id], book_data, url, book_details)
      end
    end
    logger.debug "#{book_data}"
    book_data
  end

  def self.process_search_book_data(site_data, isbn, site_ids, all_book_data, url, book)
    unless site_data.nil?
      site_data.process_page
      book_data = site_data.book_details
      book_data.each do |book_detail|
        if book_detail[:book_detail_url].nil?
          book_detail[:book_detail_url] = url
        end
        if !book_detail.empty? && !book_detail[:price].nil? && book_detail[:isbn] == isbn
          book_detail.merge!("site_id".to_sym => site_ids)
          category = book_detail[:category]
          create_category_details(category, book) unless category.nil?
          all_book_data << book_detail
        end
      end
    end
    all_book_data
  end

  def self.create_category_details(category_from_site, book_details)
    category_from_site.each do |categorys|
      sub_category = categorys.gsub(/\&/,"").split
      sub_category.each do |category|
        if category.length > 3
          category = BookCategory.where("category_name ilike '%#{category.gsub(/'s/,'')}%'")
          book_details.book_categories << category unless category.nil?
        end
      end
    end
  end

  def self.show_books_details(page)
  	self.order('occurrence DESC', 'average_rating DESC').page(page).per(12)
  end

  def self.refresh_books_detail!(fresh_list_of_books_details)
    existing_books  = {}
    database_books_details_isbn = self.pluck(:isbn)
    database_books_details_isbn.each { |isbn|
      existing_books.merge!(isbn => isbn)
    }
    destroy_books_index = 0
    create_book_metas_index = 0
    update_book_metas_index = 0
    existing_books.each do |isbn_key, value|
      if fresh_list_of_books_details.key?(isbn_key)
        book_meta_data = fresh_list_of_books_details[isbn_key][:book_meta_data]
        book_details = self.find_book_with_isbn(isbn_key).first
        all_site_id_in_meta_data = book_details.book_metas.pluck(:site_id)
        site_id_new_list = []
        book_meta_data.each do |site_id_key, meta|
          site_id_new_list << site_id_key.to_i
          old_price_list = book_details.book_metas.site_id(site_id_key).first
          if old_price_list.nil?
            meta.merge!(site_id: site_id_key)
            book_details.book_metas.create!(meta)
            create_book_metas_index = create_book_metas_index + 1
          else
            old_price_list.update_attributes(rating_count: meta[:rating_count], price: meta[:price], discount: meta[:discount], rating: meta[:rating])
            update_book_metas_index = update_book_metas_index + 1
          end
        end
        site_to_be_update = all_site_id_in_meta_data - site_id_new_list
        book_meta = self.find_book_meta(book_details, isbn_key, site_to_be_update)
        book_meta_hash = {}
        book_meta.each { |meta| book_meta_hash.merge!("#{meta[:site_id]}" => meta) }
        self.updated_book_meta(book_details, site_to_be_update, book_meta_hash)
        meta = self.calculate_rating_avg(book_meta_data.merge!(book_meta_hash))
        book_details.update_attributes(average_rating: meta[0], occurrence: site_id_new_list.count)
      else
        self.find_book_with_isbn(isbn_key).first.destroy
        destroy_books_index = destroy_books_index + 1
      end
    end
    puts "#{destroy_books_index}...books deleted"
    puts "#{create_book_metas_index}...book meta created"
    puts "#{update_book_metas_index}...book data updated"
  end

  def self.updated_book_meta(book_details, site_id, book_meta)
    site_id.each do |id|
      if book_meta.key?(id)
        meta = book_meta[id]
        book_meta_to_update = book_details.book_metas.site_id(id).first
        book_meta_to_update.update_attributes(rating_count: meta[:rating_count], price: meta[:price], discount: meta[:discount], rating: meta[:rating])
      else
        book_details.book_metas.site_id(id).first.destroy
      end
    end
  end

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
    search_data = self.pluck([:author]).uniq
    search_data << self.pluck([:title]).uniq
    search_data = search_data.join(',')
    search_data
  end

end