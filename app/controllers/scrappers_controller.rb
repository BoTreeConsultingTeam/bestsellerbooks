# require 'csv'

class ScrappersController < ApplicationController
  def price_details
    @show_book_details = BookDetail.find_book_with_id(params[:format]).first
    @price_list = BookDetail.book_price(@show_book_details)
    @avg_rating = BookDetail.avg_rating(@show_book_details)
    @category_details = @show_book_details.book_categorys.uniq
  end

  def show
    @data = BookDetail.search_books_details(params[:search],params[:page])
    @book_category = BookCategory.all
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show_books_by_category
    @data = BookCategory.find(params[:format].to_i).book_details.order('title').page(params[:page]).per(12).uniq
  end

  def refresh_details
    unique_books_details = {}
    @landmark = Utilities::Scrappers::Scrapper.create_new_landmark_scrapper
    @landmark.process_page
    @landmark_data = @landmark.book_details
    unique_books_details = BookDetail.filter_books!(@landmark_data,unique_books_details)

    @infibeam = Utilities::Scrappers::Scrapper.create_new_infibeam_scrapper
    @infibeam.process_page
    @infibeam_data = @infibeam.book_details
    unique_books_details = BookDetail.filter_books!(@infibeam_data,unique_books_details)

    @crossword = Utilities::Scrappers::Scrapper.create_new_crossword_scrapper
    @crossword.process_page
    @crossword_data = @crossword.book_details
    unique_books_details = BookDetail.filter_books!(@crossword_data,unique_books_details)

    
    @flipkart = Utilities::Scrappers::Scrapper.create_new_flipkart_scrapper
    @flipkart.process_page
    @flipkart_data = @flipkart.book_details
    unique_books_details = BookDetail.filter_books!(@flipkart_data,unique_books_details)

    @amazon = Utilities::Scrappers::Scrapper.create_new_amazon_scrapper
    @amazon.process_page
    @amazon_data = @amazon.book_details
    unique_books_details = BookDetail.filter_books!(@amazon_data,unique_books_details)
    
    BookDetail.create_or_find_book_details!(unique_books_details)
    redirect_to root_path
  end

  def show_latest_books
    # @best_wedding_venues = Utilities::Scrappers::Other::BestWeddingVenues.new
    # data = @best_wedding_venues.process_url
    # export_as_csv 'best_wedding_venues', data   
    @data = BookDetail.show_books_details(params[:page])
    @search_data = BookDetail.pluck([:author]).uniq
    @search_data << BookDetail.pluck([:title]).uniq
    @search_data = @search_data * ","
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