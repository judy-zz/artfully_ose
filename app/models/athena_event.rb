class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
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
    next_datetime = performances.empty? ? Time.now : performances.last.datetime
    next_datetime += 1.day
    next_perf = AthenaPerformance.new(:datetime=>next_datetime)
    next_perf.event = self
    next_perf
  end

  def as_widget_json(options = {})
    as_json(options).merge('performances' => upcoming_performances(:all).each{|perf| perf.add_performance_time_string }.select(&:published?))
  end

  def as_full_calendar_json
    perfs = []
    performances.each do |p|
      phash = {}
      phash['title'] = ''
      phash['start'] = p.datetime
      phash['allDay'] = false
      phash['color'] = '#034754'
      perfs << phash
    end
    perfs
  end

  def as_json(options = {})
    super({ :methods => [ 'performances', 'charts' ]}.merge(options))
  end

  def sorted_locales
    @sorted_locales ||= valid_locales.sort{|a, b| a <=> b}
  end

  def free?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? is_free
  end

  def glance
    @glance ||= AthenaGlanceReport.find(nil, :params => { :eventId => self.id, :organizationId => self.organization.id })
  end

  #return valid US states for an event
  #would be be valid states, but states also refer to state machine
  #codes defined here: http://www.itl.nist.gov/fipspubs/fip5-2.htm
  def valid_locales
    { "Alabama"=>"AL",
      "Alaska"=>"AK",
      "American Samoa"=>"AS",
      "Arizona"=>"AZ",
      "Arkansas"=>"AR",
      "California"=>"CA",
      "Colorado"=>"CO",
      "Connecticut"=>"CT",
      "Delaware"=>"DE",
      "District of Columbia"=>"DC",
      "Florida"=>"FL",
      "Georgia"=>"GA",
      "Guam"=>"GU",
      "Hawaii"=>"HI",
      "Idaho"=>"ID",
      "Illinois"=>"IL",
      "Indiana"=>"IN",
      "Iowa"=>"IA",
      "Kansas"=>"KS",
      "Kentucky"=>"KY",
      "Louisiana"=>"LA",
      "Maine"=>"ME",
      "Marshall Islands"=>"MH",
      "Maryland"=>"MD",
      "Massachusetts"=>"MA",
      "Michigan"=>"MI",
      "Micronesia"=>"FM",
      "Minnesota"=>"MN",
      "Mississippi"=>"MS",
      "Missouri"=>"MO",
      "Montana"=>"MT",
      "Nebraska"=>"NE",
      "Nevada"=>"NV",
      "New Hampshire"=>"NH",
      "New Jersey"=>"NJ",
      "New Mexico"=>"NM",
      "New York"=>"NY",
      "North Carolina"=>"NC",
      "North Dakota"=>"ND",
      "Ohio"=>"OH",
      "Oklahoma"=>"OK",
      "Oregon"=>"OR",
      "Palau"=>"PW",
      "Pennsylvania"=>"PA",
      "Rhode Island"=>"RI",
      "Puerto Rico"=>"PR",
      "South Carolina"=>"SC",
      "South Dakota"=>"SD",
      "Tennessee"=>"TN",
      "Texas"=>"TX",
      "Utah"=>"UT",
      "Vermont"=>"VT",
      "Virgin Islands"=>"VI",
      "Virginia"=>"VA",
      "Washington"=>"WA",
      "Wisconsin"=>"WI",
      "West Virginia"=>"WV",
      "Wyoming"=>"WY"}
  end

  def us_time_zones
    [ "Hawaii",
      "Alaska",
      "Pacific Time (US & Canada)",
      "Arizona",
      "Mountain Time (US & Canada)",
      "Central Time (US & Canada)",
      "Eastern Time (US & Canada)",
      "Indiana (East)" ]
  end

  private
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