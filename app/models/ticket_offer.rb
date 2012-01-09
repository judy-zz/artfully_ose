class TicketOffer < ActiveRecord::Base

  belongs_to :organization
  belongs_to :show
  belongs_to :section
  belongs_to :reseller_profile

  validates_presence_of :organization
  validates_associated :organization
  validates_numericality_of :count, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :available, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :sold, :only_integer => true, :greater_than_or_equal_to => 0
  validates_inclusion_of :status, :in => %w( creating offered accepted rejected completed )

  scope :creating, where(:status => "creating")
  scope :offered, where(:status => "offered")
  scope :accepted, where(:status => "accepted")
  scope :rejected, where(:status => "rejected")
  scope :completed, where(:status => "completed")

  def offer!
    if %w( creating offered ).include?(self.status)
      self.update_attribute :status, :offered
    else
      raise TicketOfferError.new("incorrect ticket offer sequence")
    end
  end

  def event_id
    show.event.id if show && show.event
  end

  def event
    show.event if show
  end

  class TicketOfferError < StandardError; end

end
