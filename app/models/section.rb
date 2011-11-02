class Section < ActiveRecord::Base
  include Ticket::Foundry
  foundry :with => lambda { { :section => name, :price => price, :count => capacity } }

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
    tickets = Show.find(show_id).tickets
    summary = SectionSummary.for_tickets(tickets)
  end
end