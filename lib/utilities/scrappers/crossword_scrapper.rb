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
          title = li_item.search('.variant-title a').attr('title').text().squish.strip
          author = li_item.search('.contributors .ctbr-name a').text().squish.strip
          price = li_item.search('.variant-desc .price .variant-final-price').text().strip!
          img_url = li_item.search('.variant-image a img').attr('src').text()
          href_url = 'http://www.crossword.in' + li_item.search('.variant-image a').attr('href').text()
          begin
            discount = li_item.search('.variant-desc .price .discount-badge img').attr('src').text().gsub(/\D/,'')
          rescue Exception => e
            discount = nil
          end
          meta = process_isbn_page(href_url)
          li_map = { "#{meta[0][:ISBN]}" => {
            img: img_url,            
            author: author,
            title: title,
            language: meta[0][:language],
            publisher: meta[0][:publisher],
            description: meta[1],
            category: meta[3],
            book_meta_data: {"#{site_id[:id]}" => {rating: meta[2],price: price.gsub(/\D/,''),discount: meta[0][:infibeam_price_discount],book_detail_url: href_url }}
          }}
          add_book_details(li_map)
        }
      end

      def process_isbn_page(href_url)
        meta = []
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
        category= []
        rating_div = isbn_page.search('#catalog-details .avg-cust-rating span')
        a = isbn_page.search('#browse_nodes_bc li.clearfix a')
        a.each_with_index { |a_item,index|
          category << a_item.text().squish.gsub(/\n/, '').strip
        }
        begin
          rating = rating_div.attr('rating').text()
        rescue Exception => e
          rating = nil
        end
        description = isbn_page.search('#description p').to_s
        meta << details
        meta << description
        meta << rating
        meta << category
        meta
      end
    end
  end
end