class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'events'
  self.collection_name = 'events'

  schema do
    attribute 'name', :string
    attribute 'venue', :string
    attribute 'state', :string
    attribute 'city', :string
    attribute 'producer', :string
    attribute 'producer_pid', :string
  end

  validates_presence_of :name, :venue, :city, :state, :producer, :producer_pid

  def charts
    @attributes['charts'] ||= find_charts
  end

  def charts=(charts)
    raise TypeError, "Expecting an Array" unless charts.kind_of? Array
    @attributes['charts'] ||= charts
  end

  def performances
    @attributes['performances'] ||= find_performances.sort_by { |performance| performance.datetime }
  end

  def performances=(performances)
    raise TypeError, "Expecting an Array" unless performances.kind_of? Array
    @attributes['performances'] = performances
  end

  def to_widget_json(options = {})
    performances and charts and charts.each { |chart| chart.sections }
    performances.reject! { |performance| !performance.on_sale? }
    to_json(options)
  end
  
  #return valid US states for an event
  #would be be valid states, but states also refer to state machine
  def valid_locales
    {
    'AL' => 'Alabama',
    'AK' => 'Alaska',
    'AS' => 'America Samoa',
    'AZ' => 'Arizona',
    'AR' => 'Arkansas',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DE' => 'Delaware',
    'DC' => 'District of Columbia',
    'FM' => 'Micronesia1',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'GU' => 'Guam',
    'HI' => 'Hawaii',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'IA' => 'Iowa',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'ME' => 'Maine',
    'MH' => 'Islands1',
    'MD' => 'Maryland',
    'MA' => 'Massachusetts',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MS' => 'Mississippi',
    'MO' => 'Missouri',
    'MT' => 'Montana',
    'NE' => 'Nebraska',
    'NV' => 'Nevada',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NY' => 'New York',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PW' => 'Palau',
    'PA' => 'Pennsylvania',
    'PR' => 'Puerto Rico',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VT' => 'Vermont',
    'VI' => 'Virgin Island',
    'VA' => 'Virginia',
    'WA' => 'Washington',
    'WV' => 'West Virginia',
    'WI' => 'Wisconsin',
    'WY' => 'Wyoming'
  }
  end

  private
    def find_charts
      return [] if new_record?
      AthenaChart.find(:all, :params => { :eventId => "eq#{self.id}" })
    end

    def find_performances
      return [] if new_record?
      AthenaPerformance.find(:all, :params => { :eventId => "eq#{self.id}" })
    end

 

end