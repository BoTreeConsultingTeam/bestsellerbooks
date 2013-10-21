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
      
      def self.create_new_landmark_scrapper
        Utilities::Scrappers::LandmarkScrapper.new
      end

      def self.create_new_landmark_search_book_scrapper(site_url)
        Utilities::Scrappers::LandmarkSearchBookScrapper.new(site_url)
      end

      def self.create_new_flipkart_scrapper
        Utilities::Scrappers::FlipkartScrapper.new
      end

      def self.create_new_flipkart_search_book_scrapper(site_url)
        Utilities::Scrappers::FlipkartSearchBookScrapper.new(site_url)
      end

      def self.create_new_crossword_scrapper
        Utilities::Scrappers::CrosswordScrapper.new
      end

      def self.create_new_crossword_search_book_scrapper(site_url)
        Utilities::Scrappers::CrosswordSearchBookScrapper.new(site_url)
      end

      def self.create_new_amazon_scrapper
        Utilities::Scrappers::AmazonScrapper.new
      end

      def self.create_new_amazon_search_book_scrapper(site_url)
        Utilities::Scrappers::AmazonSearchBookScrapper.new(site_url)
      end

      def crawl(unique_books_details)
        self.process_page
        unique_books_details = BookDetail.filter_books!(self.book_details, unique_books_details)
        unique_books_details
      end

    end

  end
end