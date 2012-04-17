class Event < ActiveRecord::Base
  belongs_to :organization
  belongs_to :venue
  accepts_nested_attributes_for :venue
  has_many :charts
  has_many :shows, :order => :datetime
  has_many :tickets, :through => :shows
  validate :validate_contact_phone
  
  after_create :create_default_chart

  has_attached_file :image,
    :storage => :s3,
    :path => ":attachment/:id/:style.:extension",
    :bucket => ENV["S3_BUCKET"],
    :s3_protocol => 'https',
    :s3_credentials => {
      :access_key_id => ENV["ACCESS_KEY_ID"],
      :secret_access_key => ENV["SECRET_ACCESS_KEY"]
    },
    :styles => {
      :thumb => "140x140#"
    }

  validates_presence_of :name, :organization_id

  default_scope where(:deleted_at => nil)

  delegate :time_zone, :to => :venue

  include Ticket::Reporting

  def free?
    is_free?
  end

  alias :destroy! :destroy
  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def filter_charts(charts)
    charts.reject { |chart| already_has_chart(chart) }
  end
  
  def create_default_chart
    self.charts.build({ :name => self.name, 
                        :organization => self.organization, 
                        :is_template => false }).save
  end
  
  #
  # Hack McHackerson. When we go back to multiple charts per event, this is where we start
  #
  def default_chart
    charts.first
  end

  def upcoming_shows(limit = 5)
    upcoming = shows.select { |show| show.datetime > DateTime.now.beginning_of_day }
    return upcoming if limit == :all
    upcoming.take(limit)
  end

  def played_shows(limit = 5)
    played = shows.select { |show| show.datetime < DateTime.now.beginning_of_day }
    return played if limit == :all
    played.take(limit)
  end

  def next_public_show
    upcoming_public_shows.empty? ? nil : upcoming_public_shows.first
  end

  def upcoming_public_shows
    upcoming_shows(:all).select(&:published?)
  end

  def next_show
    shows.build(:datetime => Show.next_datetime(shows.last))
    show = shows.pop
    show.chart = default_chart.dup!
    show
  end

  def as_widget_json(options = {})
    as_json(options).merge('performances' => upcoming_public_shows.as_json).merge('venue' => venue.as_json)
  end

  def as_full_calendar_json
    shows.collect do |p|
      { :title  => '',
        :start  => p.datetime_local_to_event,
        :allDay => false,
        :color  => '#077083',
        :id     => p.id
      }
    end
  end

  def as_json(options = {})
    super({ :methods => [ 'shows', 'charts' ]}.merge(options))
  end

  def assign_chart(chart)
    if already_has_chart(chart)
      self.errors[:base] << "Chart \"#{chart.name}\" has already been added to this event"
      return self
    end

    if is_free? && chart.has_paid_sections?
      self.errors[:base] << "Cannot add chart with paid sections to a free event"
      return self
    end
    chart.assign_to(self)
    self
  end

  private
  
    #
    # This is a pretty basic validation to prevent them from entering an email in the phone
    # number field (we saw this in usability testing)
    # We can't disallow numbers because some people use them in their phones (718-555-4TIX)
    #
    def validate_contact_phone
      contains_at_sign = /\@/
      if contact_phone.match contains_at_sign
        errors.add(:contact_phone, "doesn't look like a phone number.  Your changes have not been saved.")
      end
    end
  
    def already_has_chart(chart)
      !self.charts.select{|c| c.name == chart.name }.empty?
    end
end
