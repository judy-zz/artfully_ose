module ApplicationHelper
  include LinkHelper

  def check_mark
    "&#x2713;".html_safe
  end

  def time_zone_description(tz)
    ActiveSupport::TimeZone.create(tz)
  end

  def contextual_menu(&block)
    menu = ContextualMenu.new(self)
    block.call(menu)
    menu.render_menu
  end

  def widget_script(event, organization)
    return <<-EOF
<script>
  $(document).ready(function(){
    artfully.configure({
      base_uri: '#{root_url}api/',
      store_uri: '#{root_url}store/',
    });
    #{render :partial => "widgets/event", :locals => { :event => event } unless event.nil? }
    #{render :partial => "widgets/donation", :locals => { :organization => organization } unless organization.nil? }
  });
<script>
    EOF
  end

  def amount_and_nongift(item)
    str = number_as_cents item.total_price
    str += " (#{number_as_cents item.nongift_amount} Non-deductible)" unless item.nongift_amount.nil?
    str
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

  def verb_for_save(record)
    record.new_record? ? "Create" : "Update"
  end

  def select_event_for_sales_search events, event_id, default
    options =
      [
        content_tag(:option, " --- All Events --- ", :value => ""),
        content_tag(:option, "", :value => ""),
        options_from_collection_for_select(events, :id, :name, default)
      ].join

    select_tag event_id, raw(options)
  end

  def select_show_for_sales_search shows, show_id, default
    options =
      [
        content_tag(:option, " --- All Shows --- ", :value => ""),
        content_tag(:option, "", :value => ""),
        shows.map do |show|
          selected = "selected" if show.id == default.to_i
          content_tag(:option, l(show.datetime_local_to_event), :value => show.id, :selected => selected)
        end.join
      ].join

    select_tag show_id, raw(options)
  end
end
