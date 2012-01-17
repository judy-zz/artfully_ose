class ResellerEvent < ActiveRecord::Base

  belongs_to :reseller_profile

  scope :upcoming, where("datetime >= ?", Time.now)
  scope :chronological, order("datetime ASC")

  validates_presence_of :reseller_profile
  validates_associated :reseller_profile
  validates_presence_of :name
  validates_presence_of :datetime

  set_watch_for :datetime, :local_to => :organization

  def organization
    reseller_profile.organization
  end

end
