module Utilities
  module Scrappers
    class AmazonScrapper < Scrapper
      
      URL = 'http://www.amazon.in/gp/bestsellers/books/ref=sa_menu_books_bestsellers.html'
      
      def initialize
        super(URL)
      end
      def process_page
        li = page.search('#zg .zg_itemImmersion')
        site_id = Site.find_by_name("amazon")
        li.each_with_index{|li_item, index|
          title = li_item.search('.zg_itemWrapper .zg_title').text()
          author = li_item.search('.zg_itemWrapper .zg_byline').text().gsub(/by/,'')
          price = li_item.search('.zg_itemWrapper .zg_itemPriceBlock_compact .zg_price .price').text().strip.gsub(/Rs./,'')
          price = price.gsub(/.00/,'')
          img_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a img').attr('src').text()
          href_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a').attr('href').text()
          details = process_isbn_page(href_url)
          li_map = { "#{details[:ISBN]}" => {
            img: img_url,
            author: author,
            title: title,
            language: details[:language],            
            publisher: details[:publisher],
            book_meta_data: { "#{site_id[:id]}" => {price: price.gsub(/\D/,''),discount: details[:amazon_price_discount],book_detail_url: href_url }}
          }}          
          puts li_map
          add_book_details(li_map)
        }
      end
      def process_isbn_page(href_url)
        details = {}
        initialize_isbn(href_url)
        find_label = isbn_page.search('#divsinglecolumnminwidth table .bucket .content ul li')
        find_label.each_with_index { |tr_items, index|
          if tr_items.search('b').text().strip == "ISBN-13:"
            details.merge!({"ISBN".to_sym => tr_items.text().gsub(/\D/,'')[2..14]})
          elsif tr_items.search('b').text().strip == "Language:"
            details.merge!({"language".to_sym => tr_items.text().strip.gsub(/Language:/,'')})
          elsif tr_items.search('b').text().strip == "Publisher:"
            details.merge!({"publisher".to_sym => tr_items.text().strip.gsub(/Publisher:/,'')})
          end
        }
        details.merge!({"amazon_price_discount".to_sym => isbn_page.search('#handleBuy .product tr.youSavePriceRow td.price').text().strip[-6..-1].gsub(/\D/,'')})
        details
      end
    end
  end
end