module Utilities
  module Scrappers

    class CrosswordScrapper < Scrapper
      
      URL = 'http://www.crossword.in/see_more_pages/books-best-sellers-seemore-data'
      
      def initialize
        super(URL)
      end

      def process_page
        li = page.search('#content-slot ul li.clearfix')
        list = []
        li.each_with_index { |li_item, index|
          title = li_item.search('.variant-title a').attr('title').text()
          author = li_item.search('.contributors .ctbr-name a').text()
          price = li_item.search('.price .variant-final-price').text().strip!
          img_url = li_item.search('.variant-image a img').attr('src').text()
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