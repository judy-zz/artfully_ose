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
  end

  def self.search(params)
    terms = params.dup.with_indifferent_access
    limit = terms.delete(:limit) || 10
    raise ArgumentError unless terms.all? { |key, value| known_attributes.include? key }

    terms[:state] ||= "on_sale"
    terms[:_limit] = limit
    AthenaTicket.find(:all, :params => parameterize(terms)) unless terms.empty?
  end

  def expired?
    performance < DateTime.now
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

  def sell_to(buyer)
    begin
      self.buyer = buyer
      self.sell!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def comp_to(buyer)
    begin
      self.buyer = buyer
      self.comp!
    rescue Transitions::InvalidTransition
      return false
    end
  end

  def lockable?
    true
  end

  def committed?
    sold? or comped?
  end

  def to_item
    pt = PurchasableTicket.new
    pt.ticket = self
    pt
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
