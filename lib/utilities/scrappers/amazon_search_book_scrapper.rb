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
            img_url = page.search('#atfResults a img').attr('src').text()
          rescue Exception => e
            href_url = nil
            img_url = nil
          end
          site_id = Site.find_by_name("amazon")
          sub_page = page_instance(href_url)
          unless sub_page.nil?
            meta = AmazonScrapper.process_sub_page(sub_page)
            meta.merge!("book_detail_url".to_sym => href_url)
            meta.merge!("img".to_sym => img_url)
            meta.merge!("site_id".to_sym => site_id.id)
            add_book_details(meta)
          end
        end
      end
    end
  end
end