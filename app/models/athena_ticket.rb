class AthenaTicket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"
  self.collection_name = 'tickets'
  self.element_name = 'tickets'

  schema do
    attribute 'event',        :string
    attribute 'venue',        :string
    attribute 'performance',  :string
    attribute 'sold',         :string
    attribute 'on_sale',      :string
    attribute 'section',      :string
    attribute 'price',        :integer
  end

  def self.search(params)
    search_for = params.dup.reject { |key, value| !known_attributes.include? key }
    search_for[:sold] ||= "eqfalse"
    search_for[:_limit] = params[:limit] || 10
    AthenaTicket.find(:all, :params => search_for) unless search_for.empty?
  end

  def on_sale?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['on_sale'])
  end

  def sold?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['sold'])
  end

  def lockable?
    true
  end

  def to_item
    PurchasableTicket.create(:ticket_id => self.id)
  end
  
  def can_be_deleted?
    !sold?
  end

  def can_be_taken_off_sale?
    !sold?
  end
end
