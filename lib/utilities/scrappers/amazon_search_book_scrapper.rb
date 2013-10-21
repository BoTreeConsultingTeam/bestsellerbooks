module Utilities
  module Scrappers
    class AmazonSearchBookScrapper < Scrapper

      def initialize(site_url)
        super(site_url)
      end

      def process_page
        unless page.nil?
          begin
            href_url = page.search('#atfResults a').attr('href').text()
          rescue Exception => e
            href_url = nil
          end
          sub_page = page_instance(href_url)
          unless sub_page.nil?
          meta = AmazonScrapper.process_book_data_page(sub_page)
            meta.merge!("book_detail_url".to_sym => href_url)
            add_book_details(meta)            
          end
        end
      end
    end
  end
end