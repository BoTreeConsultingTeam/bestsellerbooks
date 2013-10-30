require 'nokogiri'
require 'mechanize'

module Utilities

  module Scrappers

    class Scrapper
      
      attr_accessor :page, :book_details, :isbn, :url, :book_search, :sub_page

       SITE_LIST = [:amazon, :flipkart, :landmark, :crossword, :uread, :homeshop18, :indiatimes]

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
          when :uread
            Utilities::Scrappers::UreadScrapper.new
          when :homeshop18
            Utilities::Scrappers::Homeshop18Scrapper.new
          when :indiatimes
            Utilities::Scrappers::IndiatimesScrapper.new
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
          when :uread
            Utilities::Scrappers::UreadSearchBookScrapper.new(site_url)
          when :homeshop18
            Utilities::Scrappers::Homeshop18SearchBookScrapper.new(site_url)
          when :indiatimes
            Utilities::Scrappers::IndiatimesSearchBookScrapper.new(site_url)
        end
      end

      def self.collect
        unique_books_details = {}

        SITE_LIST.each do |site|
          scrapper = get_main_page_scrapper(site)
          begin
            unique_books_details = scrapper.crawl(unique_books_details)
          rescue StandardError => e
            puts "[ERROR] Something went wrong while crawling #{site.to_s}. Scrapper would not collect books from this site"
            puts "[ERROR] #{e.message}"
            #raise e
          end
        end

        unique_books_details
      end
      
    end
  end
end