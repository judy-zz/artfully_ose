class Donation < ActiveRecord::Base
  belongs_to :cart
  belongs_to :organization

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :organization

  def price
    amount
  end

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