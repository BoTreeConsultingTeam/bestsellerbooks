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
        site_id = Site.find_by_name("crossword")
        li.each_with_index { |li_item, index|
          title = li_item.search('.variant-title a').attr('title').text()
          author = li_item.search('.contributors .ctbr-name a').text()
          price = li_item.search('.variant-desc .price .variant-final-price').text().strip!
          img_url = li_item.search('.variant-image a img').attr('src').text()
          href_url = 'http://www.crossword.in' + li_item.search('.variant-image a').attr('href').text()
          begin
            discount = li_item.search('.variant-desc .price .discount-badge img').attr('src').text().gsub(/\D/,'')
          rescue Exception => e
            discount = nil
          end
          details = process_isbn_page(href_url)
          li_map = { "#{details[:ISBN]}" => {
            img: img_url,
            
            author: author,
            title: title,
            language: details[:language],
            publisher: details[:publisher],
            book_meta_data: {"#{site_id[:id]}" => {price: price.gsub(/\D/,''),discount: details[:infibeam_price_discount],book_detail_url: href_url }}
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page(href_url)
        details = {}
        initialize_isbn(href_url)
        find_label = isbn_page.search('#features ul li')
        find_label.each_with_index { |li_item, index| 
          if li_item.search('label').text().strip == "EAN"
            details.merge!({"ISBN".to_sym => li_item.text().strip.gsub(/\D/,'')})      
          elsif li_item.search('label').text().strip == "Publisher"
            publisher = (li_item.text().strip.gsub(/Publisher/,'')).to_s
            details.merge!({"publisher".to_sym => publisher.gsub(/\W/,'')})
          elsif li_item.search('label').text().strip == "Language"
            language = (li_item.text().strip.gsub(/Language/,'')).to_s
            details.merge!({"language".to_sym => language.gsub(/\W/,'')})
          end
        }   
        details
      end
    end
  end
end