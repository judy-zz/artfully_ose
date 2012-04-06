class Section < ActiveRecord::Base
  include Ticket::Foundry
  foundry :with => lambda { { :section_id => id, :price => price, :count => capacity } }

  belongs_to :chart

  validates :name, :presence => true

  validates :price, :presence => true,
                    :numericality => true

  validates :capacity,  :presence => true,
                        :numericality => { :less_than_or_equal_to => 2000 }

  validates :description, :length => { :maximum => 300 }

  def dup!
    Section.new(self.attributes.reject { |key, value| key == 'id' })
  end

  def summarize
    tickets = Ticket.where(:show_id => chart.show.id).where(:section_id => id)
    @summary = SectionSummary.for_tickets(tickets)
  end
  
  def summary
    @summary || summarize
  end
end
