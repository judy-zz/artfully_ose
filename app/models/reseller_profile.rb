class ResellerProfile < ActiveRecord::Base

  belongs_to :organization
  has_many :ticket_offers
  has_many :reseller_events
  has_many :reseller_shows
  has_many :reseller_attachments

  validates_format_of :url, :with => URI::regexp(%w( http https ))
  validates_length_of :description, :maximum => 350
  validates_presence_of :fee

end
