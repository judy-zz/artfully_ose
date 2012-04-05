module ApplicationHelper
  include LinkHelper
  include ActionView::Helpers::NumberHelper

  def check_mark(size=nil, alt=nil)
    case size
      when :huge
        icon_tag('117-todo@2x', {:alt => alt})
      when :big
        icon_tag('117-todo', {:alt => alt})
      else
        "&#x2713;".html_safe
    end
  end
  
  #
  # just name the image, this method will prepend the path and append the .png
  # icon_tag('111-logo')
  #
  def icon_tag(img, options={})
    image_tag('glyphish/gray/' + img + '.png', options)
  end

  def time_zone_description(tz)
    ActiveSupport::TimeZone.create(tz)
  end
  
  #This is for the widget generator, DO NOT use anywhere else
  def asset_path(asset)
    javascript_path(asset).gsub(/javascripts/, 'assets')
  end
  
  def events_to_options(selected_event_id = nil)
    @events = current_user.current_organization.events
    @events_array = @events.map { |event| [event.name, event.id] }
    @events_array.insert(0, ["", ""])
    options_for_select(@events_array, selected_event_id)
  end

  def contextual_menu(&block)
    menu = ContextualMenu.new(self)
    block.call(menu)
    menu.render_menu
  end
  
  def person_link(person)
    link_to "#{person.first_name} #{person.last_name}", person_url(person)
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
  
  #This method will not prepend the $
  def number_to_dollars(cents)
    cents.to_i / 100.00
  end

  def number_as_cents(cents)
    number_to_currency(number_to_dollars(cents))
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

  def nav_dropdown(text, link='#')
    link_to ERB::Util.html_escape(text) + ' <b class="caret"></b>'.html_safe, link, :class => 'dropdown-toggle', 'data-toggle' => 'dropdown'
  end
  
  def bootstrapped_type(type)
    case type
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association, view_path = '')
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      view_path = view_path + '/' unless view_path.blank?
      template_path = view_path + association.to_s.singularize + "_fields"
      render(template_path, :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end
end
