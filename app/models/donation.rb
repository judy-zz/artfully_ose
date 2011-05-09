class Donation < ActiveRecord::Base
  belongs_to :order
  belongs_to :organization

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :organization

  def price
    amount
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