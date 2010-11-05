class Ticket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"

  schema do
    attribute 'name',         :string
    attribute 'event',        :string
    attribute 'venue',        :string
    attribute 'performance',  :string
    attribute 'sold',         :string
    attribute 'price',        :integer
  end

  def initialize(*args)
    super(*args)
    @attributes[:name] ||= 'ticket'
  end

  def self.find_by_performance(performance)
    params = {  'venue'       => "eq#{performance.venue}",
                'performance' => "eq#{performance.performed_on.as_json}",
                'event'       => "eq#{performance.title}"
             }
    self.find(:all, :params => params)
  end

  def self.generate_for_performance(performance, quantity, price)
    tickets = []
    params = {  :price        => price,
                :venue        => performance.venue,
                :performance  => performance.performed_on,
                :event        => performance.title
             }

    quantity.to_i.times do
      tickets << Ticket.create(params)
    end
    tickets
  end

  def self.search(params)
    search_for = {}

    search_for[:price] =        params[:price] unless params[:price].blank?
    search_for[:performance] =  params[:performance] unless params[:performance].blank?
    search_for[:_limit] = params[:limit] unless params[:limit].blank?
    Ticket.find(:all, :params => search_for) unless search_for.empty?
  end
end
