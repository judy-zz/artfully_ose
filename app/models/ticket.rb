class Ticket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site

  schema do
    attribute 'name',         :string
    attribute 'EVENT',        :string
    attribute 'VENUE',        :string
    attribute 'PERFORMANCE',  :string
    attribute 'SOLD',         :string
  end

  def initialize(*args)
    super(*args)
    @attributes[:name] ||= 'ticket'
  end

  def self.generate_for_performance(performance, quantity, price)
    tickets = []
    params = {  :PRICE        => price,
                :VENUE        => performance.venue,
                :PERFORMANCE  => performance.performed_on.to_s,
                :EVENT        => performance.title
             } 

    quantity.to_i.times do
      tickets << Ticket.create(params)
    end
    tickets
  end
end
