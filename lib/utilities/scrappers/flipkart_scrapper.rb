module Utilities
  module Scrappers
    class FlipkartScrapper < Scrapper
  
      URL = 'http://www.flipkart.com/view-books/l121/bestseller-literature-fiction'
      
      def initialize
        super(URL)
      end

      def process_page
        li = page.search('#search_results .fk-srch-item')
        list = []
        li.each_with_index { |li_item, index|
          title = li_item.search('.fk-sitem-image-section a img').attr('title').text()
          author = li_item.search('.fk-item-authorinfo-text a').text()
          price = li_item.search('.fk-sitem-info-section .final-price').text().strip!
          img_url = li_item.search('.fk-sitem-image-section a img').attr('src').text()
          li_map = {
            img: img_url,
            price: price,
            author: author,
            title: title
          }
          add_book_details(li_map)
        }
      end
    end
  end
end