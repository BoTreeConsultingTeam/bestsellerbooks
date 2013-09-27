require 'nokogiri'
require 'mechanize'

module Utilities
  module Scrappers

    class Scrapper
      
      attr_accessor :page, :book_details, :isbn_page, :isbn

      def initialize(url)
        agent = Mechanize.new
        @page = agent.get(url)
        @book_details = []
      end
      def initialize_isbn(url)
        agent = Mechanize.new
        @isbn_page = agent.get(url)
      end
      def add_book_details(map)
        @book_details << map
      end
      

      #
      # Public methods for creating new instance...
      #
      
      def self.create_new_landmark_scrapper
        Utilities::Scrappers::LandmarkScrapper.new
      end

      def self.create_new_infibeam_scrapper
        Utilities::Scrappers::InfibeamScrapper.new
      end

      def self.create_new_flipkart_scrapper
        Utilities::Scrappers::FlipkartScrapper.new
      end

      def self.create_new_crossword_scrapper
        Utilities::Scrappers::CrosswordScrapper.new
      end

      def self.create_new_amazon_scrapper
        Utilities::Scrappers::AmazonScrapper.new
      end
    end

  end
end