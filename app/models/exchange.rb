class Exchange
  include ActiveModel::Validations

  attr_accessor :order, :items, :tickets

  validates_presence_of :order
  validates_length_of :items,   :minimum => 1
  validates_length_of :tickets, :minimum => 1
  validate :items_are_exchangeable
  validate :tickets_match_items
  validate :tickets_are_available
  validate :tickets_belong_to_organization

  def initialize(order, items, tickets = [])
    self.order =        order
    self.items =        items
    self.tickets =      tickets
  end

  def items_are_exchangeable
    errors.add(:items, "are not available to exchange") unless items.all?(&:exchangeable?)
  end

  def tickets_match_items
    errors.add(:tickets, "must match the items to exchange") unless tickets.length == items.length
  end

  def tickets_are_available
    errors.add(:tickets, "are not available to exchange") if tickets.any?(&:committed?)
  end

  def tickets_belong_to_organization
    errors.add(:tickets, "do not belong to this organization") unless tickets.all? { |ticket| order.organization.can? :manage, ticket }
  end

  def submit
    return_items
    sell_new_items
  end

  def return_items
    items.map(&:return!)
  end

  def sell_new_items
    exchange_order_timestamp = Time.now
    tickets.each { |ticket| ticket.sell_to(order.person, exchange_order_timestamp) }
    create_athena_order(exchange_order_timestamp)
  end

  def create_athena_order(time=Time.now)
    exchange_order = AthenaOrder.new.tap do |exchange_order|
      exchange_order.person = order.person
      exchange_order.parent = order
      exchange_order.timestamp = time
      exchange_order.for_organization order.organization
      exchange_order << tickets
    end

    exchange_order.save!
  end
end