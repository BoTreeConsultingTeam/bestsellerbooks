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
        site_id = Site.find_by_name("infibeam")
        li.each_with_index { |li_item, index|
          title = li_item.search('a:first img').attr('title').text()
          author = li_item.search('a').text().gsub(/by/,'')
          price = li_item.search('.price span.normal').text()
          img_url = li_item.search('a:first img').attr('src').text()
          href_url =  'http://www.infibeam.com' + li_item.search('a:first').attr('href').text()
          details = process_isbn_page(href_url)
          li_map = { "#{details[:ISBN]}" => {
            img: img_url,
            author: author,
            title: title,
            language: details[:language],
            publisher: details[:publisher],            
            book_meta_data: {"#{site_id[:id]}" => {price: price,discount: details[:infibeam_price_discount],book_detail_url: href_url }}
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page(href_url)
        details = {}
        initialize_isbn(href_url)
        td = isbn_page.search('#ib_products table td')
        td.each_with_index { |td_items, index|
          if td_items.text().strip == "EAN:"
            details.merge!({"ISBN".to_sym => td[index+1].text().strip})
          elsif td_items.text().strip == "Publisher:"
            details.merge!({"publisher".to_sym => td[index+1].text().strip})
          elsif td_items.text().strip == "Language:"
            details.merge!({"language".to_sym => td[index+1].text().strip})
          end        
        }
        details.merge!({"infibeam_price_discount".to_sym => isbn_page.search('#priceDiv .gola .yousaveper').text().strip})
        details
      end
    end
  end
end