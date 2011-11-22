class Section < ActiveRecord::Base
  include Ticket::Foundry
  foundry :with => lambda { { :section_id => id, :price => price, :count => capacity } }

  belongs_to :chart

  validates :name, :presence => true

  validates :price, :presence => true,
                    :numericality => true

  validates :capacity,  :presence => true,
                        :numericality => { :less_than_or_equal_to => 2000 }

  def dup!
    Section.new(self.attributes.reject { |key, value| key == 'id' })
  end

  def summarize(show_id)
    tickets = Ticket.where(:show_id => show_id).where(:section_id => id)
    @summary = SectionSummary.for_tickets(tickets)
  end
  
  def summary(show_id)
    @summary || summarize(show_id)
  end
end