class Statement  
  attr_accessor :datetime, 
                :tickets_sold, 
                :tickets_comped, 
                :potential_revenue, 
                :gross_revenue, 
                :processing, 
                :net_revenue
  
  def self.for_show(show, organization)
    new.tap do |statement|
      statement.datetime = DateTime.now
      statement.tickets_sold = 0
      statement.tickets_comped = 0
      statement.potential_revenue = 0
      statement.gross_revenue = 0
      statement.processing = 0
      statement.net_revenue = 0
    end
  end
end