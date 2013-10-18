module Utilities
  module Scrappers
    class AmazonSearchBookScrapper < Scrapper

      def initialize(site_url)
        super(site_url)
      end

      def process_page
        unless page.nil?
          href_url = page.search('#atfResults a').attr('href').text()
          meta = AmazonScrapper.process_isbn_page(href_url)
          add_book_details(meta)
        end
      end
    end
  end
end