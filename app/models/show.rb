class Show < ActiveRecord::Base
  belongs_to :organization
  belongs_to :event
  belongs_to :chart

  has_many :tickets

  has_many :settlements
  has_many :items

  validates_presence_of :datetime
  validates_presence_of :chart_id
  validates_datetime :datetime, :after => lambda { Time.now }

  scope :before, lambda { |time| where("shows.datetime < ?", time) }
  scope :after,  lambda { |time| where("shows.datetime > ?", time) }
  scope :in_range, lambda { |start, stop| after(start).before(stop) }
  scope :played, lambda { where("shows.datetime < ?", Time.now) }
  scope :unplayed, lambda { where("shows.datetime > ?", Time.now) }

  include Ticket::Foundry
  foundry :using => :chart, :with => lambda {{:show_id => id, :organization_id => organization_id}}

  include Ticket::Reporting

  include ActiveRecord::Transitions
  state_machine do
    state :pending
    state :built, :enter => :create_tickets
    state :published
    state :unpublished

    event(:build)     { transitions :from => :pending, :to => :built }
    event(:publish)   { transitions :from => [ :built, :unpublished ], :to => :published }
    event(:unpublish) { transitions :from => :published, :to => :unpublished }
  end

  delegate :free?, :to => :event

  def gross_potential
    @gross_potential ||= tickets.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def gross_sales
    @gross_sales ||= tickets_sold.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def tickets_sold
    @tickets_sold ||= tickets.select { |ticket| ticket.sold? }
  end

  def tickets_comped
    @tickets_comped ||= tickets.select { |ticket| ticket.comped? }
  end

  def self.next_datetime(show)
    show.nil? ? future(Time.now.beginning_of_day + 20.hours) : future(show.datetime_local_to_organization + 1.day)
  end
  
  def datetime_local_to_organization
    datetime.in_time_zone(organization.time_zone)
  end

  def has_door_list?
    published? or unpublished?
  end

  def time_zone
    @time_zone ||= event.time_zone
  end

  def load(attrs)
    super(attrs)
    set_attributes(attrs)
  end

  def dup!
    copy = Show.new(self.attributes.reject { |key, value| key == 'id' || key == 'state' })
    copy.event = self.event
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def as_json(options={})
    { "id" => id,
      "chart_id" => chart.id,
      "state" => state,
      "show_time" => I18n.l( datetime.in_time_zone(time_zone), :format => :long_with_day)
    }
  end

  def bulk_on_sale(ids)
    targets = (ids == :all) ? tickets : tickets.where(:id => ids)
    Ticket.put_on_sale(targets)
  end

  def bulk_off_sale(ids)
    Ticket.take_off_sale(tickets.where(:id => ids))
  end

  def bulk_delete(ids)
    tickets.where(:id => ids).collect{ |ticket| ticket.id if ticket.destroy }#.compact
  end

  def bulk_change_price(ids, price)
    tickets.where(:id => ids).collect{ |ticket| ticket.id if ticket.change_price(price) }.compact
  end

  def settleables
    items.reject(&:modified?)
  end

  def live?
    (tickets_comped + tickets_sold).any?
  end

  def played?
    datetime < Time.now
  end

  def on_saleable_tickets
    tickets.select(&:on_saleable?)
  end

  def off_saleable_tickets
    tickets.select(&:off_saleable?)
  end

  def destroyable_tickets
    tickets.select(&:destroyable?)
  end

  def compable_tickets
    tickets.select(&:compable?)
  end

  private

  def self.future(date)
    return date if date > Time.now
    offset = date - date.beginning_of_day
    future(Time.now.beginning_of_day + offset + 1.day)
  end

  def bulk_comp(ids)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.comp_to }.compact
  end
end