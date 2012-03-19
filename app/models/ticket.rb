class Ticket < ActiveRecord::Base

  include ActiveRecord::Transitions

  belongs_to :buyer, :class_name => "Person"
  belongs_to :show
  belongs_to :organization
  belongs_to :section

  belongs_to :cart

  delegate :event, :to => :show

  def self.sold_after(datetime)
    sold.where("sold_at > ?", datetime)
  end

  def self.sold_before(datetime)
    sold.where("sold_at < ?", datetime)
  end

  scope :played, joins(:show).merge(Show.played)
  scope :unplayed, joins(:show).merge(Show.unplayed)

  state_machine do
    state :off_sale
    state :on_sale
    state :sold
    state :comped

    event(:on_sale)                                 { transitions :from => [ :on_sale, :off_sale, :sold ], :to => :on_sale  }
    event(:off_sale)                                { transitions :from => :on_sale,                       :to => :off_sale }
    event(:exchange, :success => :metric_exchanged) { transitions :from => [ :on_sale, :off_sale ],        :to => :sold     }
    event(:sell, :success => :metric_sold)          { transitions :from => :on_sale,                       :to => :sold     }
    event(:comp)                                    { transitions :from => [ :on_sale, :off_sale ],        :to => :comped   }
    event(:do_return)                               { transitions :from => [ :comped, :sold ],             :to => :on_sale  }
  end

  def datetime
    show.datetime_local_to_event
  end

  def as_json(options = {})
    super(options).merge!({:section => section})
  end

  def self.unsold
    where(:state => [:off_sale, :on_sale])
  end

  def self.available(params = {}, limit = 4)
    conditions = params.dup
    conditions[:state] ||= :on_sale
    conditions[:cart_id] = nil
    where(conditions).limit(limit)
  end

  def items
    @items ||= Item.find_by_product(self)
  end

  def settlement_id
    settled_item.settlement_id unless settled_item.nil?
  end

  def settled_item
    @settled_item ||= items.select(&:settled?).first
  end

  def self.fee
    0
  end

  def expired?
    datetime < DateTime.now
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
      self.exchange!
    rescue Transitions::InvalidTransition => e
      puts e
      return false
    end
  end

  def comp_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = 0
      self.sold_at = time
      self.comp!
    rescue Transitions::InvalidTransition => e
      puts e
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

  def return!
    self.buyer = nil
    update_attributes(:sold_price => nil, :sold_at => nil, :buyer_id => nil)
    do_return!
  end

  def self.put_on_sale(tickets)
    return false if tickets.blank?
    attempt_transition(tickets, :on_sale) do
      Ticket.update_all({ :state => :on_sale }, { :id => tickets.collect(&:id)})
    end
  end

  def self.take_off_sale(tickets)
    return false if tickets.blank?
    attempt_transition(tickets, :off_sale) do
      Ticket.update_all({ :state => :off_sale }, { :id => tickets.collect(&:id)})
    end
  end

  def repriceable?
    not committed?
  end

  #Bulk creation of tickets should use this method to ensure all tickets are created the same
  #Reminder that this returns a ActiveRecord::Import::Result, not an array of tickets
  def self.create_many(show, section, quantity=section.capacity)
    new_tickets = []
    (0..quantity-1).each do
      new_tickets << Ticket.new({
        :venue => show.event.venue.name,
        :price => section.price,
        :show => show,
        :organization => show.organization,
        :section => section
      })
    end
    result = Ticket.import(new_tickets)
    result
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

    def metric_sold
      RestfulMetrics::Client.add_metric(ENV["RESTFUL_METRICS_APP"], "ticket_sold", 1)
    end

    def metric_exchanged
      RestfulMetrics::Client.add_metric(ENV["RESTFUL_METRICS_APP"], "ticket_exchanged", 1)
    end

end
