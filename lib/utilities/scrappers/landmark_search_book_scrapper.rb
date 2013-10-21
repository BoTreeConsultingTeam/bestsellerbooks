module Utilities
  module Scrappers
    class LandmarkSearchBookScrapper < Scrapper

      def initialize(site_url)
        super(site_url)
      end

      def process_page
        unless page.nil?
          meta = LandmarkScrapper.process_book_data_page(page)
          add_book_details(meta)
        end
      end
    end
  end
end