module Utilities
  module Scrappers
    class Homeshop18Scrapper < Scrapper
      
      URL = 'http://www.homeshop18.com/shop/bestseller/categoryid:10000'
      
      def initialize
        super(URL)
      end

      def process_page
        books_index = 0
        puts "Started Crawling Homeshop18....."
        unless page.nil?
          site_id = Site.find_by_name("homeshop18")
          li = page.search('#bestSellerResultsDiv .books-list-item')
          li.each_with_index do |li_item, index|
            title = li_item.search('.listView_details .listView_title a').attr('title').text().squish.strip
            img_url = li_item.search('.listView_image a img').attr('data-original').text().squish
            href_url = 'http://www.homeshop18.com' + li_item.search('.listView_image a').attr('href').text().squish
            meta = process_sub_page(href_url)
            unless meta.empty? || meta[:isbn].nil?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: meta[:author],
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
        puts "Crawling Homeshop18 Completed....."
        puts "#{books_index}...books fetched from Homeshop18"
      end

      def process_sub_page(href_url)
        sub_page = page_instance(href_url)
        details = {}
        if !sub_page.nil?
          tr = sub_page.search('.product-section .more-detail-tb tr')
          tr.each_with_index do |tr_item, index|
            if tr_item.search('td.col1').text().strip == "Publisher"
              details.merge!("publisher".to_sym => tr_item.search('td.col2 span').text().strip)
            elsif tr_item.search('td.col1').text().strip == "Language"
              details.merge!("language".to_sym => tr_item.search('td.col2 a').text().strip)
            elsif tr_item.search('td.col1').text().strip == "Author"
              details.merge!("author".to_sym => tr_item.search('td.col2 a').text().strip)
            end
          end
          description = sub_page.search('.description-section .product_dscrpt_product_summary_area .product_dscrpt_summarytxt_box').to_s
          description = description.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
          details.merge!("description".to_sym => description)
          book_data = Homeshop18Scrapper.process_book_data_page(sub_page)
          details.merge!(book_data)
        end
      details
      end

      def self.process_book_data_page(sub_page)
        details = {}
        unless sub_page.nil?
          tr = sub_page.search('.product-section .more-detail-tb tr')
          tr.each_with_index do |tr_item, index|
            if tr_item.search('td.col1').text().strip == "ISBN 13"
              details.merge!("isbn".to_sym => tr_item.search('td.col2 a').text().strip)
            end
          end
          category = []
          span = sub_page.search('.breadcrumb li a span')
          span.each_with_index { |span_item, index|
            category << span_item.text().squish.strip
          }
          category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
          details.merge!("category".to_sym => category)
          details.merge!("delivery_days".to_sym => sub_page.search('#product-info .availability_box .delivery-box .days').text().gsub("Delivered in ",'').gsub(" Working Days",''))
          details.merge!("discount".to_sym => sub_page.search('.content-part .discount .rotate-box').text().gsub(/\D/,''))
          details.merge!("rating".to_sym => sub_page.search('#product-info .clearfix .rating span').text())
          details.merge!("rating_count".to_sym => sub_page.search('#product-info .clearfix .pdp_details_review_count a span').text().gsub(/\D/,''))
          details.merge!("price".to_sym => sub_page.search('#hs18Price').text().gsub(/\D/,''))
        end
        details
      end

    end
  end
end