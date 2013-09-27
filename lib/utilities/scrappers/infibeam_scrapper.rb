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
          author = li_item.search('a').text().gsub(/\D/,'')
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
            price_list: { infibeam_price: price }
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page(href_url)
        details = {}
        initialize_isbn(href_url)
        find_label = isbn_page.search('#ib_products table')
        tr = find_label.search('tr')
        tr.each_with_index { |tr_items, index|
          td =  tr_items.search('td')[0]
          if td.text().strip == "EAN:"
            details.merge!({"ISBN".to_sym => tr_items.search('td .simple').text().strip})
          elsif tr_items.search('b').text().strip == "Publisher:"
            details.merge!({"publisher".to_sym => tr_items.search('td a').text()})
          elsif td.text().strip == "Language:"
            details.merge!({"language".to_sym => tr_items.search('td')[1].text().strip})
          end
        }
        details
      end
    end
  end
end