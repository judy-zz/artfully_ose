class AthenaPerformance < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  PUT_ON_SALE = 'PUT_ON_SALE'
  TAKE_OFF_SALE = 'TAKE_OFF_SALE'
  DELETE = 'DELETE'

  schema do
    attribute 'event_id', :string
    attribute 'chart_id', :string
    attribute 'producer_id', :string
    attribute 'datetime', :string
    attribute 'tickets_created', :string
    attribute 'on_sale', :string
  end

  def gross_potential
    @gross_potential ||= tickets.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def gross_sales
    @gross_sales ||= tickets_sold.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end


  def tickets_created
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['tickets_created'])
  end
  alias :tickets_created? :tickets_created

  def on_sale
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['on_sale'])
  end
  alias :on_sale? :on_sale

  def tickets
    @tickets ||= AthenaTicket.find(:all, :params => { :performanceId => "eq#{self.id}" }).sort_by { |ticket| ticket.price }
  end

  def tickets_sold
    @tickets_sold ||= tickets.select { |ticket| ticket.sold? }
  end

  def chart
    if chart_id.blank?
      return nil
    end
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end

  def event
    @event ||= AthenaEvent.find(event_id)
  end

  def event=(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @event, self.event_id = event, event.id
  end

  #TODO: Move this into localization
  def day_of_week
    self.datetime.strftime("%A")
  end

  def formatted_performance_time
    self.datetime.strftime("%I:%M %p")
  end

  def formatted_performance_date
    self.datetime.strftime("%b, %d %Y")
  end

  def parsed_datetime
    if self.datetime.nil?
      nil
    else
      DateTime.parse(self.datetime)
    end
  end

  def update_attributes(attributes)
    prepare_attr!(attributes)
    super
  end

  def dup!
    copy = AthenaPerformance.new(self.attributes.reject { |key, value| key == 'id' || key == 'tickets_created' })
    copy.tickets_created = 'false'
    copy.on_sale = 'false'
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def datetime
    attributes['datetime'] = DateTime.parse(attributes['datetime']) if attributes['datetime'].is_a? String
    attributes['datetime']
  end

  def take_off_sale
    attributes['on_sale'] = false
    self.save
  end
  
  def put_on_sale
    tickets.each do |ticket|
      ticket.on_sale=true
      ticket.save
    end
    attributes['on_sale'] = true
    self.save
  end
    
  def bulk_edit_tickets(ticket_ids, action)    
    rejected_ids = [];
    ticket_hash = tickets.index_by(&:id)
    ticket_ids.each do |ticket_id|
      @ticket = ticket_hash[ticket_id.to_s]
      case action
        when PUT_ON_SALE
          @ticket.on_sale=true
          @ticket.save
        when TAKE_OFF_SALE
          if @ticket.can_be_taken_off_sale?
            @ticket.on_sale=false
            @ticket.save
          else
            rejected_ids << ticket_id
          end
        when DELETE
          if @ticket.can_be_deleted?
            @ticket.destroy
            self.tickets.delete @ticket
          else
            rejected_ids << ticket_id
          end
      end
    end   
    rejected_ids
  end

  private
    def prepare_attr!(attributes)
      #TODO: We need to set the correct time zone to whatever zone they're in
      unless attributes.blank?
        day = attributes.delete('datetime(3i)')
        month = attributes.delete('datetime(2i)')
        year = attributes.delete('datetime(1i)')
        hour = attributes.delete('datetime(4i)')
        minute = attributes.delete('datetime(5i)')
        attributes['datetime'] = DateTime.parse("#{year}-#{month}-#{day}T#{hour}:#{minute}:00-04:00")
      end
    end
end