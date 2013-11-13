# require 'csv'

class ScrappersController < ApplicationController

  before_filter :authenticate_user!, :check_if_admin, :only => [:refresh_details, :export_as_csv, :manually_add_books]
  
  def manually_add_books
    BookDetail.manually_add_books
    flash.now[:notice] = "Book Details Fetch completed"
  end

  def price_details
    @show_book_details = BookDetail.find_book_with_id(params[:format]).first
    @price_list = BookDetail.book_price(@show_book_details)
    @category_details = @show_book_details.book_categories
  end

  def show
    unless params[:search].nil?
      params[:search] = params[:search].gsub("'","''")
    end
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
    BookDetail.create_or_find_book_details!(Utilities::Scrappers::Scrapper.collect)
    flash.now[:notice] = "Refresh book detail completed"
  end

  def find_book_price
    book_details = BookDetail.find_by_isbn("#{params[:isbn].squish}")
    sites_ids = book_details.book_metas.pluck(:site_id)
    book_data = BookDetail.find_book_meta(book_details, "#{params[:isbn].squish}", Site::ALL_SITE_IDS - sites_ids)
    BookDetail.create_book_meta(book_details, book_data)
    BookDetail.update_average_rating(book_data, book_details)
    @new_price_list = BookDetail.book_price(book_details)
    @new_avg_rating = book_details[:average_rating]
    @new_category_details = book_details.book_categories
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

  protected

  def check_if_admin
    if signed_in?
      redirect_to root_path unless current_user.admin?
    end
  end
  
end