class DiscountsReport
  attr_accessor :discount, :discount_code, :header, :start_date, :end_date, :rows, :counts
  attr_accessor :tickets_sold, :original_price, :discounted, :gross
  extend ::ArtfullyOseHelper

  def initialize(organization, discount_code, start_date, end_date)
    if discount_code.nil?
      self.header = "ALL DISCOUNTS"
      self.discount_code = "ALL DISCOUNTS"
      self.discount = Discount.where(:organization_id => organization.id)
    else
      self.discount = Discount.where(:organization_id => organization.id).where(:id => discount_code).first
      self.discount ||= Discount.where(:organization_id => organization.id).where(:code => discount_code).first
      self.header = self.discount.code
      self.discount_code = self.discount.code
    end
  
    self.start_date = start_date
    self.end_date = end_date

    @items = Item.includes(:discount, :order => :person, :show => :event)
                 .where(:discount_id => self.discount)
                 .select('items.*, sum(items.price) as price, sum(items.original_price) as original_price')
                 .group('items.order_id')
                 .order('orders.created_at desc')

    @items = @items.where('orders.created_at > ?',self.start_date)  unless start_date.blank?
    @items = @items.where('orders.created_at < ?',self.end_date)    unless end_date.blank?

    @counts = @items.count
    self.rows = []

    @items.each do |item|
      self.rows << Row.new(item, @counts[item.order.id])
    end

    build_header

    self.tickets_sold     = @counts.values.inject{ |total, ct| total = total + ct}
    self.original_price   = @items.inject(0) { |total, item| total + item.original_price }
    self.discounted       = @items.inject(0) { |total, item| total + (item.original_price - item.price) }
    self.gross            = @items.inject(0) { |total, item| total + item.price }
  end

  def build_header
    if self.start_date.blank? && self.end_date.blank? 
      return
    elsif self.start_date.blank?
      self.header = self.header + " through #{I18n.localize(DateTime.parse(self.end_date), :format => :slashed_date)}"
    elsif self.end_date.blank?
      self.header = self.header + " since #{I18n.localize(DateTime.parse(self.start_date), :format => :slashed_date)}"
    else
      self.header = self.header + " from #{I18n.localize(DateTime.parse(self.start_date), :format => :slashed_date)} through #{I18n.localize(DateTime.parse(self.end_date), :format => :slashed_date)}"
    end
  end

  class Row
    attr_accessor :item, :ticket_count, :discounted

    def initialize(item, ticket_count)
      self.item = item
      self.discounted = item.original_price - item.price
      self.ticket_count = ticket_count
    end

    comma do
      item("Discount Code")   { |item| item.discount.code }
      item("Order")           { |item| item.order.id }
      item("Order Date")      { |item| item.order.created_at }
      item("First Name")      { |item| item.order.person.first_name }
      item("Last Name")       { |item| item.order.person.last_name }
      item("Email")           { |item| item.order.person.email }
      item("Event")           { |item| item.show.event.name }
      ticket_count
      item("Original Price")  { |item| DiscountsReport.number_as_cents item.original_price }
      discounted              { |discounted| DiscountsReport.number_as_cents discounted }
      item("Price")           { |item| DiscountsReport.number_as_cents item.price }
    end

  end

end