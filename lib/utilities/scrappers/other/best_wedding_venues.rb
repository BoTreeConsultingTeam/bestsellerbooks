require 'nokogiri'
require 'mechanize'

module Utilities
  module Scrappers
    module Other
      class BestWeddingVenues
        
        URL1 = 'http://bestweddingvenuesessex.co.uk/complete-wedding-venues-essex-list'
        URL2 = 'http://bestweddingvenuesessex.co.uk/complete-wedding-venues-essex-list?start=20'
        URL3 = 'http://bestweddingvenuesessex.co.uk/complete-wedding-venues-essex-list?start=30'

        URL_PREFIX = 'http://bestweddingvenuesessex.co.uk/'
        
        def process_url
          agent = Mechanize.new
          detailed_url_arr = []
          [URL1, URL2, URL3].each do |url|
            page = agent.get(url)
            detailed_urls = process_main_page page
            detailed_url_arr+=detailed_urls
          end
          puts "Total URLs found = #{detailed_url_arr.size}"
          all_data_map = []
          detailed_url_arr.each do |url|
            page = agent.get(url)
            arr_of_maps = get_inner_page page
            all_data_map +=  arr_of_maps
          end

          puts " Total data size = #{all_data_map.size}"
          all_data_map
        end

        def process_main_page page
          li = page.search('#res .listing')
          list = []
          li.each_with_index { |li_item, index|
            detail_page_url = li_item.search('a').attr('href').text()
            list<<"#{URL_PREFIX}#{detail_page_url}"
          }
          list
        end

        def get_inner_page page
          li = page.search('div.vcard table')
          list = []
          li.each_with_index { |li_item, index|
            name = li_item.search('td strong.org').text()
            address = li_item.search('td div.adr').text()
            contact = li_item.search('td span.tel').text()
            list<< {
              name: name,
              address: address,
              contact: contact
            }
          }
          list 
        end
      end
    end
  end
end