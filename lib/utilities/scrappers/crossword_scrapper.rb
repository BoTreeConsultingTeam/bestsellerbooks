module Utilities
  module Scrappers
    class CrosswordScrapper < Scrapper
      
      URL = 'http://www.crossword.in/see_more_pages/books-best-sellers-seemore-data'
      
      def initialize
        super(URL)
      end

      def process_page
        puts "Started Crawling Crossword....."
        unless page.nil?
          li = page.search('#content-slot ul li.clearfix')
          site_id = Site.find_by_name("crossword")
          li.each_with_index do |li_item, index|
            title = li_item.search('.variant-title a').attr('title').text().squish.strip
            author = li_item.search('.contributors .ctbr-name a').text().squish.strip
            price = li_item.search('.variant-desc .price .variant-final-price').text().strip!
            img_url = li_item.search('.variant-image a img').attr('src').text()
            href_url = 'http://www.crossword.in' + li_item.search('.variant-image a').attr('href').text()
            meta = process_sub_page(href_url)
            unless meta.empty?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: author,
                title: title,
                language: meta[:language],
                publisher: meta[:publisher],
                description: meta[:description],
                category: meta[:category],
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: price.gsub(/\D/,''), discount: meta[:discount], 
                  book_detail_url: href_url }}
              }}
              add_book_details(li_map)
            end
          end
        end
        puts "Crawling Crossword Completed....."
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
          # category= []
          # a = sub_page.search('#browse_nodes_bc li.clearfix a')
          # a.each_with_index { |a_item, index|
          #   category << a_item.text().squish.gsub(/\n/, '').strip
          # }
          # category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          # details.merge!("category".to_sym => category)
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
          category= []
          a = sub_page.search('#browse_nodes_bc li.clearfix a')
          a.each_with_index { |a_item, index|
            category << a_item.text().squish.gsub(/\n/, '').strip
          }
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
          begin
            rating = sub_page.search('#catalog-details .avg-cust-rating span').attr('rating').text()
          rescue Exception => e
            rating = nil
          end
          details.merge!("discount".to_sym => sub_page.search('#pricing_summary .discount_gola').text().gsub(/\D/,''))
          details.merge!("rating".to_sym => rating)
        end
        details
      end

    end
  end
end