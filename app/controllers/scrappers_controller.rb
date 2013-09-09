require 'csv'

class ScrappersController < ApplicationController
  def show_latest_books
    # @best_wedding_venues = Utilities::Scrappers::Other::BestWeddingVenues.new
    # data = @best_wedding_venues.process_url
    # export_as_csv 'best_wedding_venues', data
    
    @crossword = Utilities::Scrappers::Scrapper.create_new_crossword_scrapper
    @landmark = Utilities::Scrappers::Scrapper.create_new_landmark_scrapper
    @flipkart = Utilities::Scrappers::Scrapper.create_new_flipkart_scrapper
    # @infibeam = Utilities::Scrappers::Scrapper.create_new_infibeam_scrapper

    @crossword.process_page
    @landmark.process_page
    @flipkart.process_page
    # @infibeam.process_page

    @crossword_data = @crossword.book_details
    @landmark_data = @landmark.book_details
    @flipkart_data = @flipkart.book_details
    # @infibeam_data = @infibeam.book_details
    @data = @crossword_data + @landmark_data + @flipkart_data
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

