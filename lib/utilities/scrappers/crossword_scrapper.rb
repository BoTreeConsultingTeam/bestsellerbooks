module Utilities
  module Scrappers
    class CrosswordScrapper < Scrapper
      
      URL = 'http://www.crossword.in/see_more_pages/books-best-sellers-seemore-data'
      
      def initialize
        super(URL)
      end

      def process_page
        books_index = 0
        puts "Started Crawling Crossword....."
        unless page.nil?
          li = page.search('#content-slot ul li.clearfix')
          site_id = Site.find_by_name("crossword")
          li.each_with_index do |li_item, index|
            author = li_item.search('.contributors .ctbr-name a').text().squish.strip
            img_url = li_item.search('.variant-image a img').attr('src').text().squish
            title = li_item.search('.variant-image a img').attr('title').text()
            href_url = 'http://www.crossword.in' + li_item.search('.variant-image a').attr('href').text().squish
            meta = process_sub_page(href_url)
            unless meta.empty? || meta[:isbn].nil?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: author,
                title: title,
                language: meta[:language],
                publisher: meta[:publisher],
                description: meta[:description],
                category: meta[:category],
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: meta[:price], discount: meta[:discount], 
                  delivery_days: meta[:delivery_days], rating_count: meta[:rating_count], book_detail_url: href_url }}
              }}
              add_book_details(li_map)
              books_index = books_index + 1
            end
          end
        end
        puts "Crawling Crossword Completed....."
        puts "#{books_index}...books fetched from Crossword"
      end

      def process_sub_page(href_url)
        sub_page = page_instance(href_url)
        details = {}
        unless sub_page.nil?
          find_label = sub_page.search('#features ul li')
          find_label.each_with_index do |li_item, index| 
            if li_item.search('label').text().strip == "Publisher"
              publisher = (li_item.text().strip.gsub(/Publisher/,'')).to_s
              details.merge!("publisher".to_sym => publisher.gsub(/\W/,''))
            elsif li_item.search('label').text().strip == "Language"
              language = (li_item.text().strip.gsub(/Language/,'')).to_s
              details.merge!("language".to_sym => language.gsub(/\W/,''))
            end
          end
          details.merge!("description".to_sym => sub_page.search('#description p').to_s)
          book_data = CrosswordScrapper.process_book_data_page(sub_page)
          details.merge!(book_data)
        end
      details
      end

      def self.process_book_data_page(sub_page)
        details = {}
        unless sub_page.nil?
          find_label = sub_page.search('#features ul li')
          find_label.each_with_index do |li_item, index| 
            if li_item.search('label').text().strip == "EAN"
              details.merge!("isbn".to_sym => li_item.text().strip.gsub(/\D/,''))
            end
          end
          category = []
          a = sub_page.search('#browse_nodes_bc li.clearfix a')
          a.each_with_index { |a_item, index|
            category << a_item.text().squish.gsub(/\n/, '').strip
          }
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
          begin
            rating = sub_page.search('#catalog-details .avg-cust-rating span').attr('rating').text()
            rating_count = sub_page.search('#catalog-title .avg-cust-rating a').text().gsub(/\D/,'').squish.strip
          rescue Exception => e
            rating = nil
            rating_count = nil
          end
          delivery_days =  sub_page.search('#in_stock .ships-in b').text().gsub(/\ days/,'').squish
          details.merge!("delivery_days".to_sym => delivery_days)
          pricing_summary = sub_page.search('#pricing_summary')
          details.merge!("discount".to_sym => pricing_summary.search('.discount_gola').text().gsub(/\D/,''))
          details.merge!("rating".to_sym => rating)
          details.merge!("rating_count".to_sym => rating_count)
          price = pricing_summary.search('.our_price span').text().gsub(/\D/,'')
          if price.empty?
            price = pricing_summary.search('.list_price span').text().gsub(/\D/,'')
          end
          details.merge!("price".to_sym => price)
        end
        details
      end

    end
  end
end