class AthenaTicket < AthenaResource::Base
  include ActiveResource::Transitions

  self.site = Artfully::Application.config.tickets_site
  self.collection_name = 'tickets'
  self.element_name = 'tickets'

  schema do
    attribute 'id',             :string
    attribute 'event',          :string
    attribute 'event_id',       :integer
    attribute 'venue',          :string
    attribute 'performance',    :string
    attribute 'performance_id', :integer
    attribute 'section',        :string
    attribute 'price',          :integer
    attribute 'buyer_id',       :integer
    attribute 'state',          :string
    attribute 'sold_price',     :integer
    attribute 'sold_at',        :string
  end

  state_machine do
    state :off_sale
    state :on_sale
    state :sold
    state :comped

    event(:on_sale)   { transitions :from => [ :on_sale, :off_sale, :sold ],  :to => :on_sale   }
    event(:off_sale)  { transitions :from => :on_sale,                        :to => :off_sale  }
    event(:sell)      { transitions :from => :on_sale,                        :to => :sold      }
    event(:comp)      { transitions :from => [ :on_sale, :off_sale ],         :to => :comped    }
    event(:do_return) { transitions :from => [ :comped, :sold ],              :to => :on_sale   }
  end

  def self.available(params)
    terms = params.dup.with_indifferent_access
    limit = terms.delete(:limit) || 4
    raise ArgumentError unless terms.all? { |key, value| known_attributes.include? key }

    terms[:state] ||= "on_sale"
    terms[:_limit] = limit

    AthenaTicket.find(:all, :from => :available, :params => parameterize(terms)) unless terms.empty?
  end

  def self.factory(performance, section, quantity)
    attributes = {
      :event          => performance.event.name,
      :event_id       => performance.event_id,
      :venue          => performance.event.venue,
      :performance    => performance.datetime,
      :performance_id => performance.id,
      :section        => section.name,
      :price          => section.price
    }

    quantity.times.collect { create(attributes) }
  end

  def items
    @items ||= AthenaItem.find_by_product(self)
  end

  def settlement_id
    settled_item.settlement_id unless settled_item.nil?
  end

  def settled_item
    @settled_item ||= items.select(&:settled?).first
  end

  def datetime
    @performance ||= AthenaPerformance.find(performance_id)
    @performance.datetime
  end

  def price
    super.to_i
  end

  def sold_price
    super.to_i
  end

  def self.fee
    0
  end

  def expired?
    performance < DateTime.now
  end

  def refundable?
    sold?
  end

  def exchangeable?
    !expired? and sold?
  end

  def returnable?
    !expired?
  end

  def take_off_sale
    begin
      off_sale!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def put_on_sale
    begin
      on_sale!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def sell_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = self.price
      self.sold_at = time
      self.sell!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def exchange_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = 0
      self.sold_at = time
      self.sell!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def comp_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = 0
      self.sold_at = time
      self.comp!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def change_price(new_price)
    unless self.committed? or new_price.to_i < 0
      self.price = new_price
      self.save!
    else
      return false
    end
  end

  def committed?
    sold? or comped?
  end

  def on_saleable?
    !(sold? or comped?)
  end

  def off_saleable?
    on_sale?
  end

  def destroyable?
    !(sold? or comped?)
  end

  def compable?
    on_sale? or off_sale?
  end

  def destroy
    super if destroyable?
  end

  def buyer
    @buyer || find_buyer
  end

  def buyer=(person)
    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @buyer, self.buyer_id = person, person.id
  end

  def return!
    logger.debug("Returning ticket id [#{self.id}]")
    logger.debug("State is [#{self.state}]")
    self.sold_price = 0
    attributes.delete('sold_at')
    attributes.delete(:buyer_id)
    do_return!
  end

  def self.put_on_sale(tickets)
    return false if tickets.blank?
    attempt_transition(tickets, :on_sale) do
      patch(tickets, { :state => :on_sale })
    end
  end

  def self.take_off_sale(tickets)
    return false if tickets.blank?
    attempt_transition(tickets, :off_sale) do
      patch(tickets, { :state => :off_sale })
    end
  end

  def repriceable?
    not committed?
  end

  private
    def self.attempt_transition(tickets, state)
      begin
        tickets.map(&state)
        yield
      rescue Transitions::InvalidTransition
        false
      end
    end

    def find_buyer
      return if self.buyer_id.nil?

      begin
        AthenaPerson.find(self.buyer_id)
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end
end
