class Comp
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :performance, :tickets, :recipient, :reason

  def initialize(performance, tickets, recipient)
    self.performance = performance
    self.tickets = tickets
    self.recipient = recipient
  end

  def has_recipient?
    !recipient.blank?
  end

  def persisted?
    false
  end
end