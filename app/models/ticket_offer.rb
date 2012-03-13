class TicketOffer < ActiveRecord::Base

  STATUSES = %w( creating offered accepted rejected completed )

  belongs_to :organization
  belongs_to :show
  belongs_to :section
  belongs_to :reseller_profile

  validates_presence_of :organization
  validates_associated :organization
  validates_presence_of :reseller_profile
  validates_associated :reseller_profile
  validates_numericality_of :count, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :available, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :sold, :only_integer => true, :greater_than_or_equal_to => 0
  validates_inclusion_of :status, :in => STATUSES
  validates_presence_of :show
  validates_associated :show
  validates_presence_of :section
  validates_associated :section

  scope :creating, where(:status => "creating")
  scope :offered, where(:status => "offered")
  scope :accepted, where(:status => "accepted")
  scope :rejected, where(:status => "rejected")
  scope :completed, where(:status => "completed")
  scope :has_show, where("show_id IS NOT NULL")
  scope :on_calendar, has_show.where("status IN (?)", %w( accepted completed ))
  scope :visible_to_reseller, where("status IN (?)", %w( offered accepted rejected completed ))

  ## Ticket Sale Information ##
  
  def available
    [ 0, unsold - in_carts ].max
  end
  
  def unsold
    [ 0, count - sold ].max
  end

  def sold
    Order.
      includes(:items => :product).
      where(:organization_id => reseller_organization.id).
      map { |o| o.items }.
      flatten.
      compact.
      uniq.
      select { |i| i.ticket? && valid_ticket?(i.product) }.
      count
  end

  def in_carts
    Reseller::Cart.
      includes(:tickets).
      where(:reseller_id => reseller_organization.id).
      map(&:tickets).
      flatten.
      compact.
      uniq.
      select { |t| valid_ticket? t }.
      count
  end

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

  def <=>(obj)
    return 0 unless obj.kind_of? TicketOffer
    return status_sort_index <=> obj.status_sort_index
  end

  def status_sort_index
    STATUSES.index status
  end

  def reseller_organization
    reseller_profile.organization
  end

  def valid_ticket?(ticket)
    return false unless ticket.kind_of? Ticket
    ticket.organization_id == organization_id && ticket.show_id == show_id && ticket.section_id == section_id
  end

  ## Supporting Classes ##

  class TicketOfferError < StandardError; end

end
