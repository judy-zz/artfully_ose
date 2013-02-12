#
# This is the donation represented in a user's cart.  
# This is NOT the persisted item that is attached to the order
#
class Donation < ActiveRecord::Base
  include Itemable
  belongs_to :cart
  belongs_to :organization

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :organization

  def price
    amount
  end
  alias_method :cart_price, :price

  def self.fee
    0 # $0 fee
  end

  def expired?
    false
  end

  def refundable?
    true
  end

  def exchangeable?
    false
  end

  def returnable?
    false
  end
end