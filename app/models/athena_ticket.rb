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

    event :put_on_sale do
      transitions :from => [:off_sale], :to => :on_sale
    end

    event :take_off_sale do
      transitions :from => [:on_sale], :to => :off_sale
    end

    event :sell do
      transitions :from => :on_sale, :to => :sold
    end

    event :comp do
      transitions :from => [ :on_sale, :off_sale ], :to => :comped
    end
  end

  def self.search(params)
    search_for = params.dup.reject { |key, value| !known_attributes.include? key }
    search_for[:sold] ||= "eqfalse"
    search_for[:onSale] ||= "eqtrue"
    search_for[:_limit] = params[:limit] || 10
    AthenaTicket.find(:all, :params => search_for) unless search_for.empty?
  end

  def on_sale?
    attributes['state'] == "on_sale" 
  end

  def off_sale?
    state == "on_sale"
  end

  def on_sale!
    begin
      self.put_on_sale! 
    rescue Exception
      return false
    end
    save!
  end

  def off_sale!
    begin
      self.take_off_sale! 
    rescue Exception
      return false
    end
    save!
  end

  def sold!(buyer)
    begin
      self.buyer = buyer
      self.sell! 
    rescue Exception
      return false
    end
    save!
  end

 def comp!(buyer)
    begin
      self.buyer = buyer
      self.comp!
    rescue Exception
      return false
    end
    save!
  end

  def comped?
    self.state == "comped"
  end

  def sold?
    self.state == "sold"  #state machine
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
