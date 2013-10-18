module Utilities
  module Scrappers
    class LandmarkScrapper < Scrapper
      
      URL = 'http://www.landmarkonthenet.com/page/bestselling-books/'
      
      def initialize
        super(URL)
      end

      def process_page
        puts "Started crawling LandmarkOnline....."
        unless page.nil?
          li = page.search('#main-column section.productblock article.product')[1..10]
          site_id = Site.find_by_name("landmarkonthenet")
          li.each_with_index do |li_item, index|
            title = li_item.search('.info h1 a').attr('title').text().squish.strip
            author = li_item.search('.info h2 a').text().squish.strip
            img_url = li_item.search('.image a img').attr('src').text()
            href_url =  'http://www.landmarkonthenet.com' + li_item.search('.image a').attr('href').text()
            # discount = li_item.search('.image .discount').text().strip.gsub(/\D/,'')
            meta = LandmarkScrapper.process_isbn_page(href_url)
            unless meta.nil?
              li_map = { meta[:isbn] => {
                img: img_url,
                author: author,
                title: title,
                language: meta[:language],
                publisher: meta[:publisher],
                category: meta[:category],
                book_meta_data: { site_id[:id] => { price: meta[:price], discount: meta[:discount], book_detail_url: href_url }}
              }}
              add_book_details(li_map)
            end
          end
        end
        puts "Crawling LandmarkOnline completed....."
      end
      
      def self.process_isbn_page(href_url)
        isbn_page = Utilities::PageInstance.page_instance(href_url)
        details = {}
        unless isbn_page.nil?
          find_label = isbn_page.search('#tabwrapper ul.blank li')
          find_label.each_with_index do |li_item, index|
            label = li_item.search('strong').text().strip
            if label == "ISBN:"
              details.merge!("isbn".to_sym => li_item.text().strip.last(13))
            elsif label == "Publisher:"
              publisher = (li_item.text().strip.gsub(/Publisher:/,'')).to_s
              details.merge!("publisher".to_sym => publisher.gsub(/\W/,''))
            elsif label == "Language:"
              language = (li_item.text().strip.gsub(/Language:/,'')).to_s
              details.merge!("language".to_sym => language.gsub(/\W/,''))  
            end          
          end
          a = isbn_page.search('#product-breadcrumbs li a')
          category = []
          details.merge!("discount".to_sym => isbn_page.search('#thumbnailwrapper .discount-badge').text().gsub(/\D/,'').squish.strip)
          details.merge!("price".to_sym => isbn_page.search('.pricebox .price-current').text().gsub(/\D/,'').squish.strip)
          a.each_with_index { |a_item, index| category << a_item.text().squish.gsub(/\n/, '').strip }
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
        end
        details
      end
    end
  end
end