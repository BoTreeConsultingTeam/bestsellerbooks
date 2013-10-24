class BookMeta < ActiveRecord::Base
  attr_accessible :book_detail_id, :price, :discount, :book_detail_url, :site_id, :rating, :rating_count, :delivery_days
  belongs_to :book_detail
  belongs_to :site
  scope :site_id, lambda { |site_id| where(site_id: site_id) }
end