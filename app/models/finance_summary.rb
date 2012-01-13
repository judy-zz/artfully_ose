class FinanceSummary  
  attr_accessor :all_tickets, :artfully_tickets, :donations, :surcharges, :cc_fees, :settled
  
  def initialize(orders)
    @all_tickets = Tickets.new(orders)
    @artfully_tickets = Tickets.new(orders.select(&:artfully?))
  end
  
  class Tickets
    attr_accessor :gross_sales, :sold, :free, :comped
    
    def initialize(orders)
      @gross_sales = 0
      
      items = []
      orders.each do |order|
        items << order.items.select(&:ticket?)
      end
      items.flatten!
      @gross_sales  = items.inject(0) { |sum, item| sum += item.price }
      @sold         = items.select{ |item| item.product.sold? }
      @comped       = items.select{ |item| item.product.comped? }
      @free         = items.select{ |item| item.product.price == 0 }
      @comped       = items.select{ |item| item.product.comped? }
    end
  end
end