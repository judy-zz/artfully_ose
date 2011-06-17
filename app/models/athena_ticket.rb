class AthenaTicket < AthenaResource::Base
  include ActiveResource::Transitions

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

    event :on_sale do
      transitions :from => [ :off_sale, :sold ], :to => :on_sale
    end

    event :off_sale do
      transitions :from => :on_sale, :to => :off_sale
    end

    event :sell do
      transitions :from => :on_sale, :to => :sold
    end

    event :comp do
      transitions :from => [ :on_sale, :off_sale ], :to => :comped
    end

    event :do_return do
      transitions :from => [ :comped, :sold ], :to => :on_sale
    end

  end

  def self.available(params)
    terms = params.dup.with_indifferent_access
    limit = terms.delete(:limit) || 4
    raise ArgumentError unless terms.all? { |key, value| known_attributes.include? key }

    terms[:state] ||= "on_sale"
    terms[:_limit] = limit
    
    #TODO: Couldn't get self.site to parse and give up the path.
    available_endpoint = '/tix/' + self.collection_name + '/available'
    
    AthenaTicket.find(:all, :from => available_endpoint, :params => parameterize(terms)) unless terms.empty?
  end

  def price
    super.to_i
  end

  def sold_price
    super.to_i
  end

  def self.fee
    200 # $2.00 fee
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

  def destroy
    super unless sold? or comped?
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
    self.sold_at = nil
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

    def self.patch(tickets, attributes)
      response = connection.put("/tix/tickets/patch/#{tickets.collect(&:id).join(",")}", attributes.to_json, self.headers)
      format.decode(response.body).map{ |attributes| new(attributes) }
    end

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
