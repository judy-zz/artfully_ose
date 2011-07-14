module AthenaHelpers
  def setup_event(event)
    current_event(event)
    FakeWeb.register_uri(:post, "http://localhost/athena/events.json", :body => current_event.encode)
    FakeWeb.register_uri(:get, "http://localhost/athena/charts.json?organizationId=eq#{current_event.organization_id}&isTemplate=eqtrue", :body => "[]")
    FakeWeb.register_uri(:get, "http://localhost/athena/events.json?organizationId=eq#{current_event.organization_id}", :body => "[#{current_event.encode}]")
    FakeWeb.register_uri(:get, "http://localhost/athena/reports/glance/.json?eventId=eq#{current_event.id}&organizationId=eq#{current_event.organization_id}", :body => nil)
  end

  def event_from_table_row(attributes)
    attributes.merge!(:organization_id => @current_user.current_organization.id)
    Factory(:athena_event_with_id, attributes)
  end

  def current_event(event = nil)
    return @current_event if event.nil?
    @current_event = event
  end

  def setup_charts(charts = [])
    body = charts.collect { |p| p.encode }.join(",")
    FakeWeb.register_uri(:get, "http://localhost/athena/charts.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
    charts.each do |chart|
      FakeWeb.register_uri(:get, "http://localhost/athena/sections.json?chartId=eq#{chart.id}", :body => "[#{Factory(:athena_section_with_id).encode}]")
    end
    charts
  end

  def setup_performances(performances = [])
    body = performances.collect { |p| p.encode }.join(",")
    FakeWeb.register_uri(:get, "http://localhost/athena/performances.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
    current_performances(performances)
  end

  def current_performances(performances = [])
    return @current_performances if performances.empty?
    @current_performances = performances
  end

  def us_states
    {
      "Alabama"              =>"AL",
      "Alaska"               =>"AK",
      "American Samoa"       =>"AS",
      "Arizona"              =>"AZ",
      "Arkansas"             =>"AR",
      "California"           =>"CA",
      "Colorado"             =>"CO",
      "Connecticut"          =>"CT",
      "Delaware"             =>"DE",
      "District of Columbia" =>"DC",
      "Florida"              =>"FL",
      "Georgia"              =>"GA",
      "Guam"                 =>"GU",
      "Hawaii"               =>"HI",
      "Idaho"                =>"ID",
      "Illinois"             =>"IL",
      "Indiana"              =>"IN",
      "Iowa"                 =>"IA",
      "Kansas"               =>"KS",
      "Kentucky"             =>"KY",
      "Louisiana"            =>"LA",
      "Maine"                =>"ME",
      "Marshall Islands"     =>"MH",
      "Maryland"             =>"MD",
      "Massachusetts"        =>"MA",
      "Michigan"             =>"MI",
      "Micronesia"           =>"FM",
      "Minnesota"            =>"MN",
      "Mississippi"          =>"MS",
      "Missouri"             =>"MO",
      "Montana"              =>"MT",
      "Nebraska"             =>"NE",
      "Nevada"               =>"NV",
      "New Hampshire"        =>"NH",
      "New Jersey"           =>"NJ",
      "New Mexico"           =>"NM",
      "New York"             =>"NY",
      "North Carolina"       =>"NC",
      "North Dakota"         =>"ND",
      "Ohio"                 =>"OH",
      "Oklahoma"             =>"OK",
      "Oregon"               =>"OR",
      "Palau"                =>"PW",
      "Pennsylvania"         =>"PA",
      "Rhode Island"         =>"RI",
      "Puerto Rico"          =>"PR",
      "South Carolina"       =>"SC",
      "South Dakota"         =>"SD",
      "Tennessee"            =>"TN",
      "Texas"                =>"TX",
      "Utah"                 =>"UT",
      "Vermont"              =>"VT",
      "Virgin Islands"       =>"VI",
      "Virginia"             =>"VA",
      "Washington"           =>"WA",
      "Wisconsin"            =>"WI",
      "West Virginia"        =>"WV",
      "Wyoming"              =>"WY"
    }
  end

end

World(AthenaHelpers)
