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

  ## State Transitions ##

  def transition_to_status!(valid_prestatus, status)
    if valid_prestatus.include?(self.status)
      self.update_attribute :status, status
    else
      raise TicketOfferError.new("incorrect ticket offer sequence")
    end
  end

  def offer!
    transition_to_status! %w( creating offered ), "offered"
  end

  def accept!
    transition_to_status! %w( offered accepted ), "accepted"

    ProducerMailer.ticket_offer_accepted(self).deliver
  end

  def decline!(reason)
    transition_to_status! %w( offered rejected ), "rejected"
    self.update_attribute :rejection_reason, reason
    ProducerMailer.ticket_offer_rejected(self).deliver
  end

  ## Associations ##

  def event_id
    show.event.id if show && show.event
  end

  def event
    show.event if show
  end

  ## Supporting Classes ##

  class TicketOfferError < StandardError; end

end
