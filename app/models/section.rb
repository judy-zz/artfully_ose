class Section < ActiveRecord::Base
  belongs_to :chart

  validates :name, :presence => true

  validates :price, :presence => true,
                    :numericality => true

  validates :capacity,  :presence => true,
                        :numericality => { :less_than_or_equal_to => 1000 }

  def dup!
    Section.new(self.attributes.reject { |key, value| key == 'id' })
  end

  def summarize(show_id)
    tickets = Ticket.find(:all, :params => {:performanceId => "eq#{show_id}", :section => "eq#{name}"})
    summary = SectionSummary.for_tickets(tickets)
  end

  def create_tickets(show_id, new_capacity)
    attributes['show_id'] = show_id
    attributes['capacity'] = new_capacity
    tickets = ActiveSupport::JSON.decode(post(:createtickets).body)
  end
end