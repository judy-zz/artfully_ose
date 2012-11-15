class Discount < ActiveRecord::Base
  attr_accessible :active, :code, :promotion_type, :event, :organization, :creator, :properties

  belongs_to :event
  belongs_to :organization
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  validates_presence_of :code, :promotion_type, :event, :organization, :creator
  validates :code, :length => { :minimum => 4, :maximum => 15 }, :uniqueness => {:scope => :event_id}
  
  serialize :properties, HashWithIndifferentAccess

  before_validation :set_organization_from_event
  before_validation :ensure_properties_are_set

  def set_organization_from_event
    self.organization ||= self.event.try(:organization)
  end

  def apply_discount_to_cart(cart)
    ensure_discount_is_allowed(cart)
    return type.apply_discount_to_cart(cart)
  end

  def ensure_properties_are_set
    type.validate(self)
  end

  def type
    discount_class.new(self.properties)
  end

  def to_s
    type.to_s
  end

private

  def ensure_discount_is_allowed(cart)
    raise "Discount is not active!" unless self.active?
    raise "Discount won't work for this show!" unless cart.tickets.first.try(:event) == self.event
  end

  def discount_class
    "#{self.promotion_type}DiscountType".constantize
  rescue NameError
    raise "#{self.promotion_type} Discount Type has not been defined!"
  end
end
