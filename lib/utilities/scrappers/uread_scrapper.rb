module Utilities
  module Scrappers
    class UreadScrapper < Scrapper

      URL = 'http://www.uread.com/view-books/10/uread-top'

      def initialize
        super(URL)
      end

      def process_page
        books_index = 0
        puts "Started Crawling Uread....."
        unless page.nil?
          li = page.search('#listSearchResult .list-view-books')
          site_id = Site.find_by_name("uread")
          li.each do |li_item|
            title = li_item.search('.product-summary .title a').text().squish.strip
            begin
              author = li_item.search('.product-summary .author-publisher a')[0].text().squish.strip
            rescue Exception => e
              author = nil
            end
            begin
              publisher = li_item.search('.product-summary .author-publisher a')[1].text().squish.strip
            rescue Exception => e
              publisher = nil
            end
            img_url = li_item.search('.cover a img').attr('src').text()
            href_url = li_item.search('.cover a').attr('href').text()
            tr = li_item.search('.price-attrib .attributes table tr')
            tr.each do |tr_item|
              if tr_item.search('td')[0].text() == "Language:"
                language = tr_item.search('td')[1].text().squish.strip
              end
            end
            sub_page = page_instance(href_url)
            meta = UreadScrapper.process_sub_page(sub_page)
            unless meta.empty? || meta[:isbn].nil?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: author,
                title: title,
                language: nil,
                publisher: meta[:publisher],
                description: meta[:description],
                book_meta_data: { "#{site_id[:id]}" => { price: meta[:price], rating_count: meta[:rating_count], rating: meta[:rating],
                 delivery_days: meta[:delivery_days], discount: meta[:discount], book_detail_url: href_url }}
              }} 
              add_book_details(li_map)
              books_index = books_index + 1
            end
          end
        end
        puts "Crawling Uread Completed....."
        puts "#{books_index}...books fetched from Uread"
      end

      def self.process_sub_page(sub_page)
        # begin
          details = {}
          tr = sub_page.search('#bookdetail .book-details .left table tr')
          tr.each do |tr_item|
            if tr_item.search('td')[0].text() == "ISBN-13: "
              details.merge!("isbn".to_sym =>  tr_item.search('td')[1].text().gsub(/\D/,'').squish)
            end
          end
          details.merge!("description" => sub_page.search('#aboutbook').to_s)
          begin
            details.merge!("discount".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_disDiscount').text().gsub(/\D/,'').squish)
          rescue Exception => e
            details.merge!("discount".to_sym => nil)
          end
          details.merge!("delivery_days".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblBusiness b').text().gsub(" Business Days",'').squish)
          details.merge!("rating_count".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblTotalReview a').text().gsub(/\D/,'').squish)
          img = sub_page.search('.about-book .avg-customer-rating img')
          index_star = 0
          img.each do |img_item|
            if img_item.attr('alt') == "Red Star"
              index_star = index_star + 1
            end
          end
          if index_star == 0
            index_star = nil
          end
          details.merge!("rating".to_sym => index_star)
          details.merge!("price".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblourPrice').text().strip.gsub(/\D/,'').squish)
        details
      end

    end
  end
end