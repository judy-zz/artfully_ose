class Discount < ActiveRecord::Base
  attr_accessible :active, :code, :promotion_type, :event, :organization, :creator

  belongs_to :event
  belongs_to :organization
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  validates_presence_of :code, :promotion_type, :event, :organization, :creator
  validates :code, :length => { :minimum => 4, :maximum => 15 }, :uniqueness => {:scope => :event_id}
  
  serialize :properties

  before_validation :set_organization_from_event

  def set_organization_from_event
    self.organization ||= self.event.organization
  end

  def apply_discount_to_cart(cart)
    ensure_discount_is_allowed(cart)

    case self.promotion_type
    when "TenPercentOffTickets"
      cart.tickets.each do |ticket|
        ticket.update_attributes(:cart_price => ticket.price - (ticket.price * 0.1))
      end
    when "TenDollarsOffTickets"
      cart.tickets.each do |ticket|
        if ticket.price > 1000
          ticket.update_attributes(:cart_price => ticket.price - 1000)
        else
          ticket.update_attributes(:cart_price => 0)
        end
      end
    else
      raise "Discount Type has not been defined!"
    end
    return cart
  end

private

  def ensure_discount_is_allowed(cart)
    raise "Discount is not active!" unless self.active?
    raise "Discount won't work for this show!" unless cart.tickets.first.try(:event) == self.event
  end
end
