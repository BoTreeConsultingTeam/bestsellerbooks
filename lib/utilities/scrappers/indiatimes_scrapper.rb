module Utilities
  module Scrappers
    class IndiatimesScrapper < Scrapper
      
      URL = 'http://shopping.indiatimes.com/books/books-best-sellers-in-books/'
      
      def initialize
        super(URL)
      end

      def process_page
        books_index = 0
        puts "Started Crawling Indiatimes....."
        unless page.nil?
          li = page.search('.productcoloumn')
          site_id = Site.find_by_name("indiatimes")
          li.each_with_index do |li_item, index|
            title = li_item.search('.productdetail a').text().squish.strip
            author = li_item.search('.productdetail h3').text().squish.strip
            img_url = li_item.search('.productthumb a.listproductthumb img').attr('data-original').text().squish
            img_url = "http:" + img_url if img_url.match('http'||'https').nil?
            href_url = 'http://shopping.indiatimes.com' + li_item.search('.productthumb a.listproductthumb').attr('href').text().squish
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
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: meta[:price],
                 discount: meta[:discount], delivery_days: meta[:delivery_days], rating_count: meta[:rating_count], 
                 book_detail_url: href_url }}
              }}
              add_book_details(li_map)
              books_index = books_index + 1
            end
          end
        end
        puts "Crawling Indiatimes Completed....."
        puts "#{books_index}...books fetched from Indiatimes"
      end

      def process_sub_page(href_url)
        sub_page = page_instance(href_url)
        details = {}
        unless sub_page.nil?
          tr = sub_page.search('.productspecification table tr')
          tr.each_with_index do |tr_item, index|
            if tr_item.search('th').text().strip == "PUBLISHER"
              details.merge!("publisher".to_sym => tr_item.search('dd').text().strip)
            elsif tr_item.search('th').text().strip == "LANGUAGE"
              details.merge!("language".to_sym => tr_item.search('dd').text().strip)
            end
          end
          details.merge!("description".to_sym => sub_page.search('#content .productsummary .productdetail p').to_s)
          book_data = IndiatimesScrapper.process_book_data_page(sub_page)
          details.merge!(book_data)
        end
      details
      end

      def self.process_book_data_page(sub_page)
        details = {}
        tr = sub_page.search('.productspecification table tr')
        tr.each_with_index do |tr_item, index|
          if tr_item.search('th').text().strip == "ISBN-13" || tr_item.search('th').text().strip == "ISBN 13"
            details.merge!("isbn".to_sym => tr_item.search('dd').text().strip)
          end
        end
        category = []
        a = sub_page.search('#pagenav a')
        a.each_with_index { |a_item, index|
          category << a_item.text().squish.strip
        }
        category.delete_if { |sub_category| sub_category == "Books" || sub_category == "Home" }
        details.merge!("category".to_sym => category)
        details.merge!("delivery_days".to_sym => sub_page.search('#noofdays').text().strip)
        rating = sub_page.search(".producthead .rating.flt span[itemprop='ratingValue']").text()
        if rating == "0"
          rating = nil
        end
        details.merge!("discount".to_sym => sub_page.search('.productfeatures .priceinfo .pricesaving').text().gsub(/\D/,''))
        details.merge!("rating".to_sym => rating)
        details.merge!("rating_count".to_sym => sub_page.search('.producthead .quickreview span').text().gsub(/\D/,''))
        details.merge!("price".to_sym => sub_page.search('.productfeatures .priceinfo .newprice').text().gsub(/\D/, '').squish)
        details
      end

    end
  end
end