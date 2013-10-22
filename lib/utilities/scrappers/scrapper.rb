require 'nokogiri'
require 'mechanize'

module Utilities

  module Scrappers

    class Scrapper
      
      attr_accessor :page, :book_details, :isbn, :url, :book_search, :sub_page

      def initialize(url)
        begin
          @page = Mechanize.new.get(url)
        rescue => e
          @page = nil
        end
        @book_details = []
        @page
      end
      
      def page_instance(url)
        begin
          @sub_page = Mechanize.new.get(url)
        rescue => e
          @sub_page = nil
        end
        @sub_page
      end

      def add_book_details(map)
        @book_details << map
      end

      def crawl(unique_books_details)
        self.process_page
        unique_books_details = BookDetail.filter_books!(self.book_details, unique_books_details)
        unique_books_details
      end

      def self.get_main_page_scrapper(scrapper)
        case scrapper
          when :amazon
            Utilities::Scrappers::AmazonScrapper.new
          when :flipkart
            Utilities::Scrappers::FlipkartScrapper.new
          when :landmark
            Utilities::Scrappers::LandmarkScrapper.new
          when :crossword
            Utilities::Scrappers::CrosswordScrapper.new
        end
      end

      def self.get_search_page_scrapper(scrapper, site_url='')
        case scrapper
          when :amazon
            Utilities::Scrappers::AmazonSearchBookScrapper.new(site_url)
          when :flipkart
            Utilities::Scrappers::FlipkartSearchBookScrapper.new(site_url)
          when :landmark
            Utilities::Scrappers::LandmarkSearchBookScrapper.new(site_url)
          when :crossword
            Utilities::Scrappers::CrosswordSearchBookScrapper.new(site_url)
        end
      end

      def self.collect
        unique_books_details = {}

        amazon = get_main_page_scrapper(:amazon)
        unique_books_details = amazon.crawl(unique_books_details)

        flipkart = get_main_page_scrapper(:flipkart)
        unique_books_details = flipkart.crawl(unique_books_details)

        landmark = get_main_page_scrapper(:landmark)
        unique_books_details = landmark.crawl(unique_books_details)

        crossword = get_main_page_scrapper(:crossword)
        unique_books_details = crossword.crawl(unique_books_details)
      end
    end

  end
end