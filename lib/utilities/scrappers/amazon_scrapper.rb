module Utilities
  module Scrappers
    class AmazonScrapper < Scrapper
      
      URL = 'http://www.amazon.in/gp/bestsellers/books/ref=sa_menu_books_bestsellers.html'
      
      def initialize
        super(URL)
      end
      def process_page
        li = page.search('#zg .zg_itemImmersion')[1..5]
        site_id = Site.find_by_name("amazon")
        li.each_with_index{|li_item, index|
          title = li_item.search('.zg_itemWrapper .zg_title').text().squish.strip
          author = li_item.search('.zg_itemWrapper .zg_byline').text().gsub(/by/,'').squish.strip
          price = li_item.search('.zg_itemWrapper .zg_itemPriceBlock_compact .zg_price .price').text().strip.gsub(/Rs./,'')
          price = price.gsub(/.00/,'')
          img_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a img').attr('src').text()
          href_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a').attr('href').text()
          rating = li_item.search('.zg_itemWrapper .zg_reviews .swSprite span').text().strip.gsub(/ out of 5 stars/,'')
          meta = process_isbn_page(href_url)
          li_map = { "#{meta[0][:ISBN]}" => {
            img: img_url,
            author: author,
            title: title,
            language: meta[0][:language],            
            publisher: meta[0][:publisher],
            description: meta[1],
            category: meta[2],            
            book_meta_data: { "#{site_id[:id]}" => { rating: rating,price: price.gsub(/\D/,''),discount: meta[0][:amazon_price_discount],book_detail_url: href_url }}
          }}          
          add_book_details(li_map)
        }
      end
      def process_isbn_page(href_url)
        details = {}
        meta = []
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
        category = []
        details.merge!({"amazon_price_discount".to_sym => isbn_page.search('#handleBuy .product tr.youSavePriceRow td.price').text().strip[-6..-1].gsub(/\D/,'')})
        description = isbn_page.search('#outer_postBodyPS').to_s
        a = isbn_page.search('#SalesRank .zg_hrsr .zg_hrsr_ladder a')
        a.each_with_index { |a_item,index|
          if a_item.text() != "Books" || a_item.text() != "Home"
            category << a_item.text().squish.gsub(/\n/, '').strip
          end
        }
        meta << details
        meta << description
        meta << category
        meta
      end
    end
  end
end