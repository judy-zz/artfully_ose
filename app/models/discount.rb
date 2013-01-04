class Discount < ActiveRecord::Base
  attr_accessible :active, :code, :promotion_type, :event, :organization, :creator, :properties, :minimum_ticket_count
  include OhNoes::Destroy

  belongs_to :event
  belongs_to :organization
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  has_and_belongs_to_many :shows
  has_and_belongs_to_many :sections

  validates_presence_of :code, :promotion_type, :event, :organization, :creator
  validates :code, :length => { :minimum => 4, :maximum => 15 }, :uniqueness => {:scope => :event_id}
  
  serialize :properties, HashWithIndifferentAccess

  before_validation :set_organization_from_event
  before_validation :ensure_properties_are_set

  before_destroy :ensure_discount_is_destroyable

  has_many :tickets

  def set_organization_from_event
    self.organization ||= self.event.try(:organization)
  end

  def apply_discount_to_cart(cart)
    transaction do
      cart.discount = self
      ensure_discount_is_allowed(cart)
      clear_existing_discount(cart)
      type.apply_discount_to_cart(cart)
      cart.save!
    end
  end

  def ensure_properties_are_set
    type.validate
  end

  def ensure_discount_is_destroyable
    if redeemed > 0
      self.errors.add(:base, "Ticket must be unused if it is to be destroyed. Consider disabling it instead.")
      false
    else
      true
    end
  end

  def type
    discount_class.new(self)
  end

  def to_s
    type.to_s
  end

  def code
    self[:code].to_s.upcase
  end

  def minimum_ticket_count
    self[:minimum_ticket_count] || 0
  end

  def clear_existing_discount(cart)
    cart.reset_prices_on_tickets
  end

  def redeemed
    tickets.count
  end

  def destroyable?
    redeemed == 0
  end

private

  def ensure_discount_is_allowed(cart)
    raise "Discount is not active." unless self.active?
    raise "Discount won't work for this show." unless cart.tickets.first.try(:event) == self.event
    raise "You need at least #{self.minimum_ticket_count} tickets for this discount." unless cart.tickets.count >= self.minimum_ticket_count
  end

  def discount_class
    "#{self.promotion_type}DiscountType".constantize
  rescue NameError
    raise "#{self.promotion_type} Discount Type has not been defined!"
  end
end
