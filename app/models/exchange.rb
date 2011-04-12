class Exchange
  include ActiveModel::Validations

  attr_accessor :order, :items, :tickets

  validates_presence_of :order
  validates_length_of :items,   :minimum => 1
  validates_length_of :tickets, :minimum => 1
  validate :tickets_match_items

  def initialize(order, items, tickets = [])
    self.order =        order
    self.items =        items
    self.tickets =      tickets
  end

  def tickets_match_items
    errors.add(:tickets, "must match the items to exchange") unless tickets.length == items.length
  end

  def submit
    return_items and sell_new_items
  end

  def return_items
    items.map(&:return_item).all?
  end

  def sell_new_items
    tickets.each { |ticket| ticket.sell_to(order.person) }
    create_athena_order
  end

  def create_athena_order
    exchange_order = AthenaOrder.new.tap do |exchange_order|
      exchange_order.person = order.person
      exchange_order.parent = order
      exchange_order.for_organization order.organization
      exchange_order.for_items tickets
    end

    exchange_order.save!
  end
end