module Utilities
  module Scrappers
    class UreadSearchBookScrapper < Scrapper

      def initialize(site_url)
        super(site_url)
      end

      def process_page
        unless page.nil?
          meta = UreadScrapper.process_sub_page(page)
          add_book_details(meta)
        end
      end
    end
  end
end