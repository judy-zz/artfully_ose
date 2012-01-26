class ResellerEvent < ActiveRecord::Base

  belongs_to :reseller_profile
  belongs_to :venue
  has_many :reseller_shows
  has_many :reseller_attachments, :as => :attachable
  delegate :organization, :to => :reseller_profile
  delegate :time_zone, :to => :venue

  accepts_nested_attributes_for :venue

  validates_presence_of :reseller_profile
  validates_associated :reseller_profile
  validates_presence_of :name
  validates_presence_of :producer
  validates_presence_of :venue

  scope :alphabetical, order(:name)

  def organization
    reseller_profile.organization
  end

  def next_show
    reseller_shows.build(:datetime => Show.next_datetime(reseller_shows.last))
    reseller_shows.pop
  end

end
