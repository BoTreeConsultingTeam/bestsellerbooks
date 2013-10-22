# require 'csv'

class ScrappersController < ApplicationController
  def price_details
    @show_book_details = BookDetail.find_book_with_id(params[:format]).first
    @price_list = BookDetail.book_price(@show_book_details)
    @avg_rating = BookDetail.avg_rating(@show_book_details)
    @category_details = @show_book_details.book_categorys.uniq
  end

  def show
    @data = BookDetail.search_books_details(params[:search], params[:page])
    @book_category = BookCategory.all
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show_books_by_category
    @data = BookCategory.books_category(params[:format].to_i, params[:page])
  end

  def refresh_details
    unique_books_details = {}

    @amazon = Utilities::Scrappers::Scrapper.create_new_amazon_scrapper
    unique_books_details = @amazon.crawl(unique_books_details)

    @flipkart = Utilities::Scrappers::Scrapper.create_new_flipkart_scrapper
    unique_books_details = @flipkart.crawl(unique_books_details)
      
    @landmark = Utilities::Scrappers::Scrapper.create_new_landmark_scrapper
    unique_books_details = @landmark.crawl(unique_books_details)

    @crossword = Utilities::Scrappers::Scrapper.create_new_crossword_scrapper
    unique_books_details = @crossword.crawl(unique_books_details)
    
    BookDetail.create_or_find_book_details!(unique_books_details)
    redirect_to root_path
  end

  def find_book_price
    book_details = BookDetail.find_by_isbn("#{params[:isbn].squish}")
    all_site = Site.pluck(:id)
    sites_id = book_details.book_metas.pluck(:site_id)
    
    BookDetail.find_book_meta(book_details, "#{params[:isbn].squish}", sites_id)
    new_meta_data = all_site - sites_id
    @new_price_list = book_details.book_metas.where(site_id: new_meta_data)
    @new_avg_rating = BookDetail.avg_rating(book_details)
  end

  def show_latest_books
    # @best_wedding_venues = Utilities::Scrappers::Other::BestWeddingVenues.new
    # data = @best_wedding_venues.process_url
    # export_as_csv 'best_wedding_venues', data   
    @data = BookDetail.show_books_details(params[:page])
    @search_data = BookDetail.auto_search_data
    @book_category = BookCategory.all
  end
  
  def export_as_csv file_name_prefix, data
    @outfile = "#{file_name_prefix}_" + Time.now.strftime("%m-%d-%Y") + ".csv"

    csv_data = CSV.generate do |csv|

      csv << [
          'No',
          'Name',
          'Address',
          'Contact'
      ]

      data.each_with_index do |value_map, index|
          csv << [
              index+1,
              value_map[:name],
              value_map[:address],
              value_map[:contact]
          ]
      end

    end

    send_data csv_data,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{@outfile}"

  end
end