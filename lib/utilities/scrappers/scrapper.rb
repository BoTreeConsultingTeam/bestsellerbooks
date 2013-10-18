require 'nokogiri'
require 'mechanize'

module Utilities

  class PageInstance

    attr_accessor :isbn_page

    def self.page_instance(url)
      begin
        @isbn_page = Mechanize.new.get(url)
      rescue => e
        @isbn_page = nil
      end
      @isbn_page
    end

  end

  module Scrappers

    class Scrapper
      
      attr_accessor :page, :book_details, :isbn, :url, :book_search

      def initialize(url)
        begin
          @page = Mechanize.new.get(url)
        rescue => e
          @page = nil
        end
        @book_details = []
        @page
      end
      
      def add_book_details(map)
        @book_details << map
      end
      
      def self.create_new_landmark_scrapper
        Utilities::Scrappers::LandmarkScrapper.new
      end

      def self.create_new_infibeam_scrapper
        Utilities::Scrappers::InfibeamScrapper.new
      end

      def self.create_new_flipkart_scrapper
        Utilities::Scrappers::FlipkartScrapper.new
      end

      def self.create_new_crossword_scrapper(site_url)
        Utilities::Scrappers::CrosswordScrapper.new(site_url)
      end

      def self.create_new_amazon_scrapper
        Utilities::Scrappers::AmazonScrapper.new
      end

      def self.create_new_amazon_search_book_scrapper(site_url)
        Utilities::Scrappers::AmazonSearchBookScrapper.new(site_url)
      end
    end

  end
end