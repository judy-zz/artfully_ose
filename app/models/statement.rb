class Statement  
  attr_accessor :datetime, 
                :tickets_sold, 
                :tickets_comped, 
                :potential_revenue, 
                :gross_revenue, 
                :processing, 
                :net_revenue,
                :due,
                :settled,
                :payment_method_hash
  
  def self.for_show(show, organization)
    if show.nil? || organization.nil?
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
      statement.due               = show.items.inject(0)  { |due, item| due += item.net if item.order.credit? }
      statement.settled           = show.settlements.inject(0) { |settled, settlement| settled += settlement.net }
      
      statement.payment_method_hash         = show.items.group_by { |item| item.order.payment_method }
    end
  end
end