class SectionSummary
  attr_accessor :total, :sold, :comped
  
  def self.for_tickets(tickets = [])
    summary = SectionSummary.new
    summary.total = tickets.size
    summary.sold = tickets.select{|t| t.sold?}.size
    summary.comped = tickets.select{|t| t.comped?}.size
    summary
  end
end