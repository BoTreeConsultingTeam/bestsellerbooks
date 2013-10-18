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

    @flipkart = Utilities::Scrappers::Scrapper.create_new_flipkart_scrapper
    unique_books_details = process_page(@flipkart, unique_books_details)
    
    @landmark = Utilities::Scrappers::Scrapper.create_new_landmark_scrapper
    unique_books_details = process_page(@landmark, unique_books_details)

    @crossword = Utilities::Scrappers::Scrapper.create_new_crossword_scrapper("http://www.crossword.in/see_more_pages/books-best-sellers-seemore-data")
    unique_books_details = process_page(@crossword, unique_books_details)

    @amazon = Utilities::Scrappers::Scrapper.create_new_amazon_scrapper
    unique_books_details = process_page(@amazon, unique_books_details)
    
    BookDetail.create_or_find_book_details!(unique_books_details)
    redirect_to root_path
  end

  def process_page(site, unique_books_details)
    site.process_page
    unique_books_details = BookDetail.filter_books!(site.book_details, unique_books_details)
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