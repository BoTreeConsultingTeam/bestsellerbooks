class GuestPost < ActiveRecord::Base
  attr_accessible :email, :message, :name, :subject

  validates_presence_of :name, :email, :message
  validates :email, format: { with: /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/,
                                      message: "address is invalid" }, unless: "email.blank?"
end
