class Statement  
  attr_accessor :datetime, 
                :tickets_sold, 
                :tickets_comped, 
                :potential_revenue, 
                :gross_revenue, 
                :processing, 
                :net_revenue,
                :cc_net,
                :settled,
                :payment_method_rows,
                :order_location_rows,
                :discount_rows
  
  def self.for_show(show, imported=false)
    if show.nil?
      return new
    end
    
    new.tap do |statement|
      statement.datetime          = show.datetime_local_to_event
      statement.tickets_sold      = show.tickets.select{|t| t.sold?}.size
      statement.tickets_comped    = show.tickets.select{|t| t.comped?}.size
      statement.potential_revenue = show.tickets.inject(0) { |total_price, ticket| total_price += ticket.price }
      statement.gross_revenue     = show.items.inject(0) { |gross, item| gross += item.price }
      statement.net_revenue       = show.items.inject(0) { |net, item| net += item.net }
      statement.processing        = statement.gross_revenue - statement.net_revenue
      
      #
      # This is the business rule definition of money due to a producer.  
      # It's important not to use show.settlebles here because *this is the check that show.settlables works*. 
      # If show.settleables is broken, this will show that
      #
      # Also settleables goes down when settlements are issued.  This doesn't
      #
      
      statement.cc_net = 0
      show.items.includes(:order).each do |item|
        statement.cc_net += item.net if (item.order.credit? && !imported)
      end
      statement.settled           = show.settlements.successful.inject(0) { |settled, settlement| settled += settlement.net }
      payment_method_hash         = show.items.group_by { |item| item.order.payment_method }
      
      #
      # PAYMENT METHOD
      #

      statement.payment_method_rows         = {}
      
      # Initialize with the three common payment types
      statement.payment_method_rows[::CreditCardPayment.payment_method.downcase] = PaymentTypeRow.new(::CreditCardPayment.payment_method)
      statement.payment_method_rows[::CashPayment.payment_method.downcase] = PaymentTypeRow.new(::CashPayment.payment_method)
      statement.payment_method_rows[::CompPayment.payment_method.downcase] = PaymentTypeRow.new(::CompPayment.payment_method)
      
      payment_method_hash.each do |payment_method, items|
        payment_method = (payment_method.try(:downcase) || "")
        row = statement.payment_method_rows[payment_method] || PaymentTypeRow.new(payment_method)
        items.each {|item| row << item}
        statement.payment_method_rows[payment_method] = row
      end
      
      #
      # ORDER LOCATION
      #  
      order_location_hash         = show.items.group_by do |item| 
        order = item.order
        order.parent.nil? ? order.location : order.parent.location 
      end
      
      statement.order_location_rows = {}
      statement.order_location_rows[::WebOrder.location]        = OrderLocationRow.new(::WebOrder.location)
      statement.order_location_rows[BoxOffice::Order.location]  = OrderLocationRow.new(BoxOffice::Order.location)
      
      order_location_hash.each do |order_location, items|
        row = statement.order_location_rows[order_location] || OrderLocationRow.new(order_location)
        items.each {|item| row << item}
        statement.order_location_rows[order_location] = row
      end

      statement.build_discount_rows(show.items)
    end
  end

  def build_discount_rows(items)
    self.discount_rows         = {}
    items.each do |item|
      unless item.product.discount.nil?
        row = self.discount_rows[item.product.discount.code] || DiscountRow.new(item.product.discount.code, item.product.discount.promotion_type)
        row << item
        row.discount += (item.product.price - item.product.sold_price)
        self.discount_rows[item.product.discount.code] = row
      end
    end
  end
  
  module Row
    attr_accessor :tickets, 
                  :gross,
                  :processing,
                  :net
    
    def<<(item)
      if item.refund?
        self.tickets = self.tickets - 1
      elsif item.exchanged? || item.return?
        #Noop
      else
        self.tickets = self.tickets + 1   
      end
      
      self.gross        = self.gross + item.price
      self.processing   = self.processing + (item.realized_price - item.net)
      self.net          = self.net + item.net
    end
  end
  
  class DiscountRow
    include Row
    attr_accessor   :discount_code, :type, :discount
    
    def initialize(discount_code, type)
      self.discount_code = discount_code
      self.type = type
      self.tickets = 0
      self.gross = 0
      self.processing = 0
      self.net = 0
      self.discount = 0
    end
  end
  
  class OrderLocationRow
    include Row
    attr_accessor   :order_location
    
    def initialize(order_location)
      self.order_location = order_location
      self.tickets = 0
      self.gross = 0
      self.processing = 0
      self.net = 0
    end
  end
  
  class PaymentTypeRow
    include Row
    attr_accessor   :payment_method
    
    def initialize(payment_method)
      self.payment_method = payment_method
      self.tickets = 0
      self.gross = 0
      self.processing = 0
      self.net = 0
    end
  end
end