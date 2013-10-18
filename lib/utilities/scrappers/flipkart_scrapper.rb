module Utilities
  module Scrappers
    class FlipkartScrapper < Scrapper

      URL = 'http://www.flipkart.com/view-books/l121/bestseller-literature-fiction'

      def initialize
        super(URL)
      end

      def process_page
        puts "Started Crawling Flipkart....."
        unless page.nil?
          li = page.search('#search_results .fk-srch-item')
          site_id = Site.find_by_name("flipkart")
          li.each_with_index do |li_item, index|
            title = li_item.search('.fk-sitem-image-section a img').attr('title').text().squish.strip
            price = li_item.search('.fk-sitem-info-section .final-price').text().gsub(/\D/,'').squish.strip
            discount =  li_item.search('.fk-sitem-info-section .fk-font-small').text().gsub(/\D/,'')
            img_url = li_item.search('.fk-sitem-image-section .rposition a img').attr('data-src').text()
            href_url = 'http://www.flipkart.com' + li_item.search('.fk-sitem-image-section a').attr('href').text()
            meta = FlipkartScrapper.process_isbn_page(href_url)
            unless meta.empty?
              li_map = { meta[:isbn] => {
                img: img_url,
                author: meta[:author],
                title: title,
                language: meta[:language],
                publisher: meta[:publisher],
                category: meta[:category],           
                description: meta[:description],
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: price, discount: meta[:discount], book_detail_url: href_url }}
              }}
              add_book_details(li_map)
            end
          end
        end
        puts "Crawling Flipkart Completed....."
      end
      
      def self.process_isbn_page(href_url)
        isbn_page = Utilities::PageInstance.page_instance(href_url)
        details = {}
        unless isbn_page.nil?
          tr = isbn_page.search('#specifications .fk-specs-type2')
          td = tr.search("tr")
          td.each_with_index do |td_items, index|
            t =  td_items.search('.specs-key').text()
            if t == "ISBN-13"
              details.merge!("isbn".to_sym => td_items.search('.specs-value').text())
            elsif t == "Language"
              details.merge!("language".to_sym => td_items.search('.specs-value').text())
            elsif t == "Publisher"              
              details.merge!("publisher".to_sym => td_items.search('.specs-value').text())
            elsif t == "Author" || t == "Authored By"
              details.merge!("author".to_sym => td_items.search('.specs-value a').text())
            end
          end
          category = []
          # details.merge!("img_url".to_sym => isbn_page.search('#visible-image-small').attr('src').text())
          details.merge!("discount".to_sym => isbn_page.search('#topsection .prices .fk-uppercase').text().gsub(/\D/,''))
          details.merge!("price".to_sym => isbn_page.search('#topsection .prices .pprice')[0].text().gsub(/\D/,''))
          details.merge!("rating".to_sym => isbn_page.search('.ratings-section .pp-big-star').text())
          a = isbn_page.search('#fk-mainbody-id .fk-lbreadbcrumb span a')
          a.each_with_index { |a_item, index| category << a_item.text().squish.gsub(/\n/, '').strip }
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
          details.merge!("description".to_sym => isbn_page.search('#description .item_desc_text p').to_s)
        end
        details
      end
    end
  end
end