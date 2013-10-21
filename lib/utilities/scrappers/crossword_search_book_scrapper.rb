module Utilities
  module Scrappers
    class CrosswordSearchBookScrapper < Scrapper

      def initialize(site_url)
        super(site_url)
      end

    	def process_page
        li = page.search('#content-slot ul li.clearfix')
        li.each_with_index do |li_item, index|
          price = li_item.search('.variant-desc .price .variant-final-price').text().gsub(/\D/,'').strip
          begin
            href_url = 'http://www.crossword.in' + li_item.search('.variant-image a').attr('href').text()
          rescue Exception => e
            href_url = nil
          end
          sub_page = page_instance(href_url)
          unless sub_page.nil?
            meta = CrosswordScrapper.process_book_data_page(sub_page)
            meta.merge!("price".to_sym => price,"book_detail_url".to_sym => href_url)
            add_book_details(meta)
          end
        end
      end
    end
  end
end