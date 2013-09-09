module Utilities
  module Scrappers
    class LandmarkScrapper < Scrapper
      
      URL = 'http://www.landmarkonthenet.com/page/bestselling-books/'
      
      def initialize
        super(URL)
      end

      def process_page
        li = page.search('#main-column section.productblock article.product')
        list = []
        li.each_with_index { |li_item, index|
          title = li_item.search('.info h1 a').attr('title').text()
          author = li_item.search('.info h2 a').text()
          price = li_item.search('.buttons .prices .pricelabel').text().strip!
          img_url = li_item.search('.image a img').attr('src').text()
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