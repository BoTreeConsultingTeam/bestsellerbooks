module Utilities
  module Scrappers
    class InfibeamScrapper < Scrapper
      
      URL = 'http://www.infibeam.com/Books/best-selling-showcase.html'
      
      def initialize
        super(URL)
      end

      def process_page
        li = page.search('#staticpage .boxinnerbig ul li')
        list = []
        li.each_with_index { |li_item, index|
          title = li_item.search('a:first img').attr('title').text()
          author = li_item.search('a')[1].text()
          price = li_item.search('.price span.normal').text()
          img_url = li_item.search('a:first img').attr('src').text()
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