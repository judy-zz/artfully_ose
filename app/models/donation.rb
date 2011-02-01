class Donation < ActiveRecord::Base
  belongs_to :order

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :producer_pid

  def recipient
    @recipient ||= AthenaPerson.find(self.athena_id)
  end

  def price
    amount
  end

  def recipient=(recipient)
    raise TypeError, "Expecting an AthenaPerson" unless recipient.kind_of? AthenaPerson
    @recipient, self.producer_pid = recipient, recipient.id
  end
end