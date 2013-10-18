module Utilities
  module Scrappers
    class AmazonScrapper < Scrapper

      URL = 'http://www.amazon.in/gp/bestsellers/books/ref=sa_menu_books_bestsellers.html'

      def initialize
        super(URL)
      end

      def process_page
        puts "Started Crawling Amazon....."
        unless page.nil?
          li = page.search('#zg .zg_itemImmersion')
          site_id = Site.find_by_name("amazon")
          li.each_with_index do |li_item, index|
            title = li_item.search('.zg_itemWrapper .zg_title').text().squish.strip
            author = li_item.search('.zg_itemWrapper .zg_byline').text().gsub(/by/,'').squish.strip
            price = li_item.search('.zg_itemWrapper .zg_itemPriceBlock_compact .zg_price .price').text().strip.gsub(/Rs./,'')
            price = price.gsub(/.00/,'')
            img_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a img').attr('src').text()
            href_url = li_item.search('.zg_itemWrapper .zg_image .zg_itemImageImmersion a').attr('href').text()
            rating = li_item.search('.zg_itemWrapper .zg_reviews .swSprite span').text().strip.gsub(/ out of 5 stars/,'')
            meta = AmazonScrapper.process_isbn_page(href_url)
            unless meta.empty?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: author,
                title: title,
                language: meta[:language],            
                publisher: meta[:publisher],
                description: meta[:description],
                category: meta[:category],            
                book_meta_data: { "#{site_id[:id]}" => { rating: rating, price: price.gsub(/\D/,''), discount: meta[:discount], book_detail_url: meta[:url] }}
              }}          
              add_book_details(li_map)
            end
          end
        end
        puts "Crawling Amazon Completed....."
      end
      
      def self.process_isbn_page(href_url)
        isbn_page = Utilities::PageInstance.page_instance(href_url)
        details = {}
        unless isbn_page.nil?
          find_label = isbn_page.search('#divsinglecolumnminwidth table .bucket .content ul li')
          find_label.each_with_index { |tr_items, index|
            if tr_items.search('b').text().strip == "ISBN-13:"
              details.merge!("isbn".to_sym => tr_items.text().gsub(/\D/,'')[2..14])
            elsif tr_items.search('b').text().strip == "Language:"
              details.merge!("language".to_sym => tr_items.text().strip.gsub(/Language:/,''))
            elsif tr_items.search('b').text().strip == "Publisher:"
              details.merge!("publisher".to_sym => tr_items.text().strip.gsub(/Publisher:/,''))
            end
          }
          category = []
          begin
            details.merge!("discount".to_sym => isbn_page.search('#handleBuy .product tr.youSavePriceRow td.price').text().strip[-6..-1].gsub(/\D/,''))
          rescue Exception => e
            details.merge!("discount".to_sym => nil)
          end
          details.merge!("description" => isbn_page.search('#outer_postBodyPS').to_s)
          a = isbn_page.search('#SalesRank .zg_hrsr .zg_hrsr_ladder a')
          a.each_with_index { |a_item, index|
            category << a_item.text().squish.gsub(/\n/, '').strip
          }
          details.merge!("url".to_s => href_url)
          details.merge!("rating".to_sym => isbn_page.search('.jumpBar .asinReviewsSummary .swSprite span').text().strip.gsub(/ out of 5 stars/,'').strip.gsub(/See all reviews/,''))
          details.merge!("price".to_sym => isbn_page.search('#actualPriceValue span').text().strip.gsub(/.00/,'').gsub(/\D/,''))
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
        end
        details
      end
    end
  end
end