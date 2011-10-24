class Statement  
  attr_accessor :datetime, 
                :tickets_sold, 
                :tickets_comped, 
                :potential_revenue, 
                :gross_revenue, 
                :processing, 
                :net_revenue
  
  def self.for_show(show, organization)
    if show.nil? || organization.nil?
      return new
    end
    
    new.tap do |statement|
      statement.datetime = show.datetime
      statement.tickets_sold = show.tickets.select{|t| t.sold?}.size
      statement.tickets_comped = show.tickets.select{|t| t.comped?}.size
      statement.potential_revenue = show.tickets.inject(0) { |total_price, ticket| total_price += ticket.price }
      statement.gross_revenue = 0
      statement.processing = 0
      statement.net_revenue = 0
    end
  end
end