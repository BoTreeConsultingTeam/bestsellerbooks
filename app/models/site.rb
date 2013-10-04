class Site < ActiveRecord::Base
  attr_accessible :name
  has_one :book_meta
  
  def self.site_name(id)
    s = Site.find_by_id(id)
    s[:name]
  end
end
