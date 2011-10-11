class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'events'
  self.collection_name = 'events'

  schema do
    attribute 'id', :integer
    attribute 'name', :string
    attribute 'venue', :string
    attribute 'state', :string
    attribute 'city', :string
    attribute 'time_zone', :string
    attribute 'producer', :string
    attribute 'organization_id', :integer
    attribute 'is_free', :string
  end

  validates_presence_of :name, :venue, :city, :state, :producer, :organization_id, :time_zone

  def charts
    @attributes['charts'] ||= find_charts
  end

  def charts=(charts)
    raise TypeError, "Expecting an Array" unless charts.kind_of? Array
    @attributes['charts'] ||= charts
  end

  def filter_charts(charts)
    charts.reject { |chart| already_has_chart(chart) }
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end

  def performances
    @attributes['performances'] ||= find_performances.sort_by { |performance| performance.datetime }
  end

  def upcoming_performances(limit = 5)
    Time.zone = time_zone
    upcoming = performances.select { |performance| performance.datetime > DateTime.now.beginning_of_day }
    return upcoming if limit == :all
    upcoming.take(limit)
  end

  def played_performances(limit = 5)
    Time.zone = time_zone
    played = performances.select { |performance| performance.datetime < DateTime.now.beginning_of_day }
    return played if limit == :all
    played.take(limit)
  end

  def performances=(performances)
    raise TypeError, "Expecting an Array" unless performances.kind_of? Array
    @attributes['performances'] = performances
  end

  def next_perf
    next_datetime = AthenaPerformance.next_datetime(performances.last)
    next_perf = AthenaPerformance.new({:datetime => next_datetime, :event_id => self.id})
    next_perf.event = self
    next_perf
  end

  def as_widget_json(options = {})
    as_json(options).merge('performances' => upcoming_performances(:all).each{|perf| perf.add_performance_time_string }.select(&:published?))
  end

  def as_full_calendar_json
    performances.collect do |p|
      { :title  => '',
        :start  => p.datetime,
        :allDay => false,
        :color  => '#077083',
        :id     => p.id
      }
    end
  end

  def as_json(options = {})
    super({ :methods => [ 'performances', 'charts' ]}.merge(options))
  end

  def free?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? is_free
  end

  def glance
    @glance ||= AthenaGlanceReport.find(nil, :params => { :eventId => self.id, :organizationId => self.organization_id })
  end

  def assign_chart(chart)
    if already_has_chart(chart)
      self.errors[:base] << "Chart \"#{chart.name}\" has already been added to this event"
      return self
    end

    if free? && chart.has_paid_sections?
      self.errors[:base] << "Cannot add chart with paid sections to a free event"
      return self
    end
    chart.assign_to(self)
    self
  end

  private
    def already_has_chart(chart)
      !self.charts.select{|c| c.name == chart.name }.empty?
    end

    def find_charts
      return [] if new_record?
      AthenaChart.find(:all, :params => { :eventId => "eq#{self.id}" }).each do |chart|
        chart.event = self
      end
    end

    def find_performances
      return [] if new_record?
      AthenaPerformance.find(:all, :params => { :eventId => "eq#{self.id}" }).each do |performance|
        performance.event = self
      end
    end

end