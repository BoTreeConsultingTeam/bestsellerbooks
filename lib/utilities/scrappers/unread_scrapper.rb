module Utilities
  module Scrappers
    class UnreadScrapper < Scrapper

      URL = 'http://www.uread.com/view-books/10/uread-top'

      def initialize
        super(URL)
      end

      def process_page
        puts "Started Crawling Unread....."
        unless page.nil?
          li = page.search('#listSearchResult .list-view-books')
          site_id = Site.find_by_name("unread")
          li.each do |li_item|
            title = li_item.search('.product-summary .title a').text().squish.strip
            author = li_item.search('.product-summary .author-publisher a')[0].text().squish.strip
            begin
              publisher = li_item.search('.product-summary .author-publisher a')[1].text().squish.strip
            rescue Exception => e
              publisher = nil
            end
            img_url = li_item.search('.cover a img').attr('src').text()
            href_url = li_item.search('.cover a').attr('href').text()
            # td = li_item.search('.price-attrib .attributes table tr td')
            # td.each_with_index do |td_item, index|
            #   if td_item.text() == "Language:"
            #     # language = td_item[index + 1].text()
            #   end
            # end
            sub_page = page_instance(href_url)
            puts href_url
            meta = UnreadScrapper.process_sub_page(sub_page)
            unless meta.empty?
              li_map = { "#{meta[:isbn]}" => {
                img: img_url,
                author: author,
                title: title,
                language: nil,
                publisher: meta[:publisher],
                description: meta[:description],
                rating_count: meta[:rating_count],
                description: meta[:description],
                delivery_days: meta[:meta],
                book_meta_data: { "#{site_id[:id]}" => { rating: meta[:rating], price: meta[:price],
                 discount: meta[:discount], book_detail_url: href_url }}
              }} 
              puts li_map
              add_book_details(li_map)
            end
          end
        end
        puts "Crawling Unread Completed....."
      end

      def self.process_sub_page(sub_page)
        details = {}
        details.merge!("isbn".to_sym => sub_page.search('#bookdetail .book-details .left table tr td')[1].text().gsub(/\D/,'').squish)
        details.merge!("description" => sub_page.search('#aboutbook').to_s)
        begin
          details.merge!("discount".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_disDiscount').text().gsub(/\D/,'').squish)
        rescue Exception => e
          details.merge!("discount".to_sym => nil)
        end
        details.merge!("delivery_days".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblBusiness b').text().squish.strip)
        # details.merge!("shipping_detail".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblBusiness b').text().squish.strip)
        details.merge!("rating_count".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblTotalReview a').text().gsub(/\D/,'').squish)
        img = sub_page.search('.about-book .avg-customer-rating img')
        index_star = 0
        img.each do |img_item|
          if img_item.attr('href') == "Red Star"
            index_star = index_star + 1
          end
        end
        details.merge!("rating".to_sym => index_star)
        details.merge!("price".to_sym => sub_page.search('#ctl00_phBody_ProductDetail_lblourPrice').text().strip.gsub(/\D/,'').squish)
        details
      end
      
    end
  end
end