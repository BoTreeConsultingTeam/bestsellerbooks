class BookMeta < ActiveRecord::Base
  attr_accessible :book_detail_id, :price, :discount, :book_detail_url, :site_id
  belongs_to :book_detail
  belongs_to :site
end
