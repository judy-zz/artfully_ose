class AthenaStatement < AthenaResource::Base
  self.site = Artfully::Application.config.reports_site
  self.element_name = "statement"
  self.collection_name = "statement"
  
  def self.for_performance(performance_id, organization_id)
    statement = self.find(nil, :params => { :performanceId => performance_id, :organizationId => organization_id})
    
    # Calling this a monkey-patch would be insulting to monkeys.  It's cool in light of bingo!
    statement.expenses.expenses[1].units = statement.sales.performances[0].gross_revenue
    statement.expenses.expenses[1].expense = (statement.sales.performances[0].gross_revenue - statement.sales.performances[0].net_revenue)
    statement.sales.performances[0].processing = (statement.sales.performances[0].gross_revenue - statement.sales.performances[0].net_revenue)
    statement
  end
end