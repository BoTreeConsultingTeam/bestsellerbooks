module Utilities
  module Scrappers
    class FlipkartScrapper < Scrapper

      URL = 'http://www.flipkart.com/view-books/l121/bestseller-literature-fiction'

      def initialize
        super(URL)
      end

      def process_page
        books_index = 0
        puts "Started Crawling Flipkart....."
        unless page.nil?
          li = page.search('#search_results .fk-srch-item')
          site_id = Site.find_by_name("flipkart")
          li.each_with_index do |li_item, index|
            title = li_item.search('.fk-sitem-image-section a img').attr('title').text().squish.strip
            discount =  li_item.search('.fk-sitem-info-section .fk-font-small').text().gsub(/\D/,'')
            img_url = li_item.search('.fk-sitem-image-section .rposition a img').attr('data-src').text()
            href_url = 'http://www.flipkart.com' + li_item.search('.fk-sitem-image-section a').attr('href').text()
            meta = process_sub_page(href_url)
            unless meta.empty? || meta[:isbn].nil?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: meta[:author],
                title: title,
                language: meta[:language],
                publisher: meta[:publisher],
                category: meta[:category],
                description: meta[:description],
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: meta[:price], discount: meta[:discount], delivery_days: meta[:delivery_days],
                  rating_count: meta[:rating_count], book_detail_url: href_url }}
              }}
              add_book_details(li_map)
              books_index = books_index + 1
            end
          end
        end
        puts "Crawling Flipkart Completed....."
        puts "#{books_index}...book fetched from Flipkart"
      end

      def process_sub_page(href_url)
        sub_page = page_instance(href_url)
        details = {}
        unless sub_page.nil?
          tr = sub_page.search('#specifications .fk-specs-type2')
          td = tr.search("tr")
          td.each_with_index do |td_items, index|
            t =  td_items.search('.specs-key').text()
            if t == "Language"
              details.merge!("language".to_sym => td_items.search('.specs-value').text())
            elsif t == "Publisher"              
              details.merge!("publisher".to_sym => td_items.search('.specs-value').text())
            elsif t == "Author" || t == "Authored By"
              details.merge!("author".to_sym => td_items.search('.specs-value a').text())
            end
          end
          details.merge!("description".to_sym => sub_page.search('#description .item_desc_text p').to_s)
          book_data = FlipkartScrapper.process_book_data_page(sub_page)
          details.merge!(book_data)
        end
        details
      end

      def self.process_book_data_page(sub_page)
        details = {}
        tr = sub_page.search('#specifications .fk-specs-type2')
        td = tr.search("tr")
        td.each_with_index do |td_items, index|
          t =  td_items.search('.specs-key').text()
          if t == "ISBN-13"
            details.merge!("isbn".to_sym => td_items.search('.specs-value').text())
          end
        end
        category = []
        a = sub_page.search('#fk-mainbody-id .fk-lbreadbcrumb span a')
        a.each_with_index { |a_item, index| category << a_item.text().squish.gsub(/\n/, '').strip }
        category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
        details.merge!("category".to_sym => category)
        details.merge!("discount".to_sym => sub_page.search('#topsection .prices .fk-uppercase').text().gsub(/\D/,''))
        begin
          details.merge!("price".to_sym => sub_page.search('#topsection .prices .pprice')[0].text().gsub(/\D/,''))
        rescue => e
          details.merge!("price".to_sym => nil)
        end
        
        details.merge!("delivery_days".to_sym => sub_page.search('.mprod-summary .right-stock-sec .shipping-details .fk-font-bold').text().gsub(/\ business days./,'').squish)
        details.merge!("rating_count".to_sym => sub_page.search('.ratings-section .tpadding10 span').text().gsub(/\D/,'').squish)
        details.merge!("rating".to_sym => sub_page.search('.ratings-section .line .pp-big-star').text())
        details
      end

    end
  end
end