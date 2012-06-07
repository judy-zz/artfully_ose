class ResellerEvent < ActiveRecord::Base

  belongs_to :reseller_profile
  belongs_to :venue
  has_many :reseller_shows
  has_many :shows, :class_name => "ResellerShow"
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
  scope :published, includes(:reseller_shows).where(:reseller_shows => { :state => :published })

  def organization
    reseller_profile.organization
  end

  def next_show
    reseller_shows.build(:datetime => Show.next_datetime(reseller_shows.last))
    reseller_shows.pop
  end

  def as_full_calendar_json(options = {})
    shows = if options[:published_only] then reseller_shows.published else reseller_shows end
    shows.collect do |s|
      {
        :title  => '',
        :start  => s.datetime_local_to_event,
        :allDay => false,
        :color  => '#077083',
        :id     => s.id
      }
    end
  end

  def attachment_by(reseller_profile)
    self.reseller_attachments.where(:reseller_profile_id => reseller_profile.id).first
  end

end
