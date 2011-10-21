class Event < ActiveRecord::Base
  belongs_to :organization

  has_many :charts
  has_many :shows, :order => :datetime
  has_many :tickets, :through => :shows

  validates_presence_of :name, :venue, :city, :state, :producer, :organization_id, :time_zone

  include Ticket::Reporting

  def free?
    is_free?
  end

  def filter_charts(charts)
    charts.reject { |chart| already_has_chart(chart) }
  end

  def upcoming_shows(limit = 5)
    Time.zone = time_zone
    upcoming = shows.select { |show| show.datetime > DateTime.now.beginning_of_day }
    return upcoming if limit == :all
    upcoming.take(limit)
  end

  def played_shows(limit = 5)
    Time.zone = time_zone
    played = shows.select { |show| show.datetime < DateTime.now.beginning_of_day }
    return played if limit == :all
    played.take(limit)
  end

  def next_show
    shows.build(:datetime => Show.next_datetime(shows.last))
  end

  def as_widget_json(options = {})
    as_json(options).merge('performances' => upcoming_shows(:all).each{|perf| perf.add_show_time_string }.select(&:published?))
  end

  def as_full_calendar_json
    shows.collect do |p|
      { :title  => '',
        :start  => p.datetime,
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
    def already_has_chart(chart)
      !self.charts.select{|c| c.name == chart.name }.empty?
    end
end