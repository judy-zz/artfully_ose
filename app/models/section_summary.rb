class SectionSummary
  attr_accessor :total, :sold, :comped, :on_sale
  
  def self.for_tickets(tickets = [])
    summary = SectionSummary.new
    summary.total = tickets.size
    summary.on_sale = tickets.select{|t| t.on_sale?}.length
    summary.sold = tickets.select{|t| t.sold?}.length
    summary.comped = tickets.select{|t| t.comped?}.length
    summary
  end
end