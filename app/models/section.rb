class Section < ActiveRecord::Base
  include Ticket::Foundry
  foundry :with => lambda { { :section_id => id, :price => price, :count => capacity } }

  belongs_to :chart
  has_many :tickets

  validates :name, :presence => true

  validates :price, :presence => true,
                    :numericality => true

  validates :capacity,  :presence => true,
                        :numericality => { :less_than_or_equal_to => 2000 }

  validates :description, :length => { :maximum => 500 }

  def dup!
    Section.new(self.attributes.reject { |key, value| key == 'id' })
  end
  
  def self.price_to_cents(price_in_dollars)
    (price_in_dollars.to_f * 100).to_i
  end

  def summarize
    tickets = Ticket.where(:show_id => chart.show.id).where(:section_id => id)
    @summary = SectionSummary.for_tickets(tickets)
  end
  
  def put_on_sale(qty = 0)
    tickets.off_sale.limit(qty).each do |t|
      t.put_on_sale
    end
  end
  
  def take_off_sale(qty = 0)
    tickets.on_sale.limit(qty).each do |t|
      t.take_off_sale
    end
  end
  
  def summary
    @summary || summarize
  end

  def as_json(options = {})
    options ||= {}
    super(:methods => :summary).merge(options)
  end
end
