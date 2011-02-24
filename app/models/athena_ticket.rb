class AthenaTicket < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"
  self.collection_name = 'tickets'
  self.element_name = 'tickets'

  schema do
    attribute 'id',             :integer
    attribute 'event',          :string
    attribute 'event_id',       :integer
    attribute 'venue',          :string
    attribute 'performance',    :string
    attribute 'performance_id', :integer
    attribute 'sold',           :string
    attribute 'on_sale',        :string
    attribute 'section',        :string
    attribute 'price',          :integer
    attribute 'buyer_id',       :integer
  end

  def self.search(params)
    search_for = params.dup.reject { |key, value| !known_attributes.include? key }
    search_for[:sold] ||= "eqfalse"
    search_for[:onSale] ||= "eqtrue"
    search_for[:_limit] = params[:limit] || 10
    AthenaTicket.find(:all, :params => search_for) unless search_for.empty?
  end

  def on_sale?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['on_sale'])
  end

  def on_sale!
    self.on_sale = true
    save!
  end

  def off_sale!
    return false if sold?
    self.on_sale = false
    save!
  end

  def off_sale?
    not on_sale?
  end

  def sold!(buyer)
    self.buyer = buyer
    self.sold = true
    save!
  end

  def sold?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['sold'])
  end

  def lockable?
    true
  end

  def to_item
    pt = PurchasableTicket.new
    pt.ticket = self
    pt
  end

  def destroy
    super unless sold?
  end

  def buyer
    @buyer || find_buyer
  end

  def buyer=(person)
    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @buyer, self.buyer_id = person, person.id
  end

  private
    def find_buyer
      return if self.buyer_id.nil?

      begin
        AthenaPerson.find(self.buyer_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:buyer_id, nil)
        return nil
      end
    end
end
