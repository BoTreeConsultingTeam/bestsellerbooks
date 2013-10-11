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
          title = li_item.search('.fk-sitem-image-section a img').attr('title').text().squish.strip
          price = li_item.search('.fk-sitem-info-section .final-price').text().gsub(/\D/,'').squish.strip
          discount =  li_item.search('.fk-sitem-info-section .fk-font-small').text().gsub(/\D/,'')
          img_url = li_item.search('.fk-sitem-image-section .rposition a img').attr('data-src').text()
          href_url = 'http://www.flipkart.com' + li_item.search('.fk-sitem-image-section a').attr('href').text()
          initialize_isbn(href_url)
          book_meta = process_isbn_page          
          li_map = { "#{book_meta[0][:ISBN]}" => {
            img: img_url,
            author: book_meta[0][:author],
            title: title,
            language: book_meta[0][:language],
            publisher: book_meta[0][:publisher],
            category: book_meta[3],           
            description: book_meta[1],
            book_meta_data: {"#{site_id[:id]}" => {rating: book_meta[2],price: price,discount: discount,book_detail_url: href_url }}
          }}
          add_book_details(li_map)
        }
      end
      def process_isbn_page
        book_meta = []
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
        category = []
        rating = isbn_page.search('.ratings-section .pp-big-star').text()
        a = isbn_page.search('#fk-mainbody-id .fk-lbreadbcrumb span a')
        a.each_with_index { |a_item,index|
          category << a_item.text().squish.gsub(/\n/, '').strip
        }
        category.delete_if {|x| x == "Books" || x == "Home" }
        description = isbn_page.search('#description .item_desc_text p').to_s
        book_meta << details        
        book_meta << description
        book_meta << rating
        book_meta << category
        book_meta
      end
    end
  end
end