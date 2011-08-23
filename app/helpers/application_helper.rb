module ApplicationHelper
  include LinkHelper

  def contextual_menu(&block)
    menu = ContextualMenu.new(self)
    block.call(menu)
    menu.render_menu
  end

  def widget_script(event, organization)
    return <<-EOF
$(document).ready(function(){
  artfully.configure({
    base_uri: '#{root_url}api/',
    store_uri: '#{root_url}store/',
  });
  #{render :partial => "widgets/event", :locals => { :event => event } unless event.nil? }
  #{render :partial => "widgets/donation", :locals => { :organization => organization } unless organization.nil? }
});
    EOF
  end

  def number_as_cents(cents)
    number_to_currency(cents.to_i / 100.00)
  end

  def sorted_us_state_names
    @sorted_us_states ||= us_states.sort{|a, b| a <=> b}
  end

  def sorted_us_state_abbreviations
    @sorted_us_states ||= us_states.invert.keys.sort{|a, b| a <=> b}
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
