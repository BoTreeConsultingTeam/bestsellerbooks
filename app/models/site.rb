class Site < ActiveRecord::Base
  ALL_SITE_IDS = pluck(:id)
  attr_accessible :name
  has_one :book_meta
  scope :site_name, lambda { |site_id| where(id: site_id) }
end
