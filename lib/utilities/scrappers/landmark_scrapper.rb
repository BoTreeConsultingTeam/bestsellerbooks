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
          price = li_item.search('.buttons .prices .pricelabel').text().gsub(/\D/,'')
          img_url = li_item.search('.image a img').attr('src').text()
          href_url =  'http://www.landmarkonthenet.com' + li_item.search('.image a').attr('href').text()
          details = process_isbn_page(href_url)
          li_map = { "#{details[:ISBN]}" => {
            img: img_url,
            author: author,
            title: title,
            language: details[:language],
            publisher: details[:publisher],        
            price_list: { landmarkonthenet_price: price }
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page(herf_url)
        details = {}
        initialize_isbn(herf_url)
        find_label = isbn_page.search('#tabwrapper ul.blank li')
        find_label.each_with_index { |li_item, index|
          label = li_item.search('strong').text().strip
          if label == "ISBN:"
            details.merge!({"ISBN".to_sym => li_item.text().strip.last(13)})
          elsif label == "Publisher:"
            publisher = (li_item.text().strip.gsub(/Publisher:/,'')).to_s
            details.merge!({"publisher".to_sym => publisher.gsub(/\W/,'')})
          elsif label == "Language:"
            language = (li_item.text().strip.gsub(/Language:/,'')).to_s
            details.merge!({"language".to_sym => language.gsub(/\W/,'')}) 
          end          
        }    
        details
      end
    end
  end
end