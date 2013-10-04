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
        site_id = Site.find_by_name("flipkart")
        li.each_with_index { |li_item, index|
          title = li_item.search('.fk-sitem-image-section a img').attr('title').text()
          #author = li_item.search('.fk-item-authorinfo-text a').text()
          price = li_item.search('.fk-sitem-info-section .final-price').text().gsub(/\D/,'')
          discount =  li_item.search('.fk-sitem-info-section .fk-font-small').text().gsub(/\D/,'')
          img_url = li_item.search('.fk-sitem-image-section .rposition a img').attr('data-src').text()
          href_url = 'http://www.flipkart.com' + li_item.search('.fk-sitem-image-section a').attr('href').text()
          initialize_isbn(href_url)
          details = process_isbn_page
          li_map = { "#{details[:ISBN]}" => {
            img: img_url,
            author: details[:author],
            title: title,
            language: details[:language],
            publisher: details[:publisher],
            
            book_meta_data: {"#{site_id[:id]}" => {price: price,discount: discount,book_detail_url: href_url }}
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page
        details = {}        
        tr = isbn_page.search('#specifications .fk-specs-type2')
        td = tr.search("tr")
        td.each_with_index { |td_items, index|
          t =  td_items.search('.specs-key').text()
          if t == "ISBN-13"
            details.merge!({"ISBN".to_sym => td_items.search('.specs-value').text()})  
          elsif t == "Language"
            details.merge!({"language".to_sym => td_items.search('.specs-value').text()})  
          elsif t == "Publisher"              
            details.merge!({"publisher".to_sym => td_items.search('.specs-value').text()})  
          elsif t == "Author" || t == "Authored By"
            details.merge!({"author".to_sym => td_items.search('.specs-value a').text()})
          end
        }
        details
      end   
    end
  end
end