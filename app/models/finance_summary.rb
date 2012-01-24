class FinanceSummary  
  attr_accessor :all_tickets, :artfully_tickets, :donations, :service_fees, :processing_fees, :settlements
  
  def initialize(orders, settlements)
    @all_tickets = Tickets.new(orders)
    @artfully_tickets = Tickets.new(orders.select(&:artfully?))
    @donations = Donations.new(orders.select(&:artfully?))
    @processing_fees = ProcessingFees.new(orders.select(&:artfully?), @artfully_tickets.sold, @donations.num_donations)
    @service_fees = ServiceFees.new(orders.select(&:artfully?))
    @settlements = Settlements.new(settlements)
  end
  
  class Settlements
    attr_accessor :net_settlements, :num_settlements, :num_failed_settlements
    
    def initialize(settlements)
      @net_settlements = 0
      @num_settlements = 0
      @num_failed_settlements = 0
      settlements.each do |settlement|
        if settlement.success?
          @net_settlements += settlement.net
          @num_settlements += 1
        else
          @num_failed_settlements += 1
        end
      end  
    end
  end
  
  class ServiceFees
    attr_accessor :gross_fees, :num_tickets
    
    def initialize(orders)
      @gross_fees = 0
      orders.each do |order| 
        @gross_fees += order.service_fee unless order.service_fee.nil?
      end
      @num_tickets = FinanceSummary.select_items(orders, :ticket?).select{ |item| item.product.sold? }.length
    end    
  end
  
  class ProcessingFees
    attr_accessor :gross_fees, :num_tickets, :num_donations
    
    def initialize(orders, tickets_sold, num_donations)
      items = FinanceSummary.select_items(orders, nil)
      @gross_fees  = items.inject(0) { |sum, item| sum += (item.price - item.net) }
      @num_tickets = tickets_sold.length
      @num_donations = num_donations
    end
  end
  
  class Donations
    attr_accessor :gross_donations, :num_donations
    
    def initialize(orders)
      @gross_donations = 0
      @num_donations = 0
      items = FinanceSummary.select_items(orders, :donation?)
      @gross_donations  = items.inject(0) { |sum, item| sum += item.price }
      @num_donations = items.length
    end
  end
  
  class Tickets
    attr_accessor :gross_sales, :sold, :free, :comped
    
    def initialize(orders)
      @gross_sales = 0
      
      items = FinanceSummary.select_items(orders, :ticket?)
      @gross_sales  = items.inject(0) { |sum, item| sum += item.price }
      @sold         = items.select{ |item| item.product.sold? }
      @comped       = items.select{ |item| item.product.comped? }
      @free         = items.select{ |item| item.product.price == 0 }
      @comped       = items.select{ |item| item.product.comped? }
    end
  end
  
  def self.select_items(orders, proc)
    items = []
    orders.each do |order|
      items << order.items.select(&proc)
    end
    items.flatten   
  end
end