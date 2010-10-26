class Ticket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"

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

  def self.find_by_performance(performance)
    params = {  'VENUE'       => "eq#{performance.venue}",
                'PERFORMANCE' => "eq#{performance.performed_on.as_json}",
                'EVENT'       => "eq#{performance.title}"
             }
    self.find(:all, :params => params)
  end

  def self.generate_for_performance(performance, quantity, price)
    tickets = []
    params = {  :PRICE        => price,
                :VENUE        => performance.venue,
                :PERFORMANCE  => performance.performed_on,
                :EVENT        => performance.title
             }

    quantity.to_i.times do
      tickets << Ticket.create(params)
    end
    tickets
  end

  def self.search(params)
    search_for = {}

    search_for[:PRICE] =        params[:PRICE] unless params[:PRICE].blank?
    search_for[:PERFORMANCE] =  params[:PERFORMANCE] unless params[:PERFORMANCE].blank?
    search_for[:_limit] = params[:limit] unless params[:limit].blank?
    Ticket.find(:all, :params => search_for) unless search_for.empty?
  end
end
