class Event < ActiveRecord::Base
  belongs_to :organization

  has_many :charts
  has_many :shows, :order => :datetime
  has_many :tickets, :through => :shows

  validates_presence_of :name, :venue, :city, :state, :producer, :organization_id, :time_zone

  def free?
    is_free?
  end

  def filter_charts(charts)
    charts.reject { |chart| already_has_chart(chart) }
  end

  def upcoming_performances(limit = 5)
    Time.zone = time_zone
    upcoming = shows.select { |show| show.datetime > DateTime.now.beginning_of_day }
    return upcoming if limit == :all
    upcoming.take(limit)
  end

  def played_performances(limit = 5)
    Time.zone = time_zone
    played = shows.select { |show| show.datetime < DateTime.now.beginning_of_day }
    return played if limit == :all
    played.take(limit)
  end

  def next_perf
    build_performance(:datetime => Show.next_datetime(shows.last))
  end

  def as_widget_json(options = {})
    as_json(options).merge('performances' => upcoming_performances(:all).each{|perf| perf.add_performance_time_string }.select(&:published?))
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
    super({ :methods => [ 'performances', 'charts' ]}.merge(options))
  end

  def glance
    @glance ||= AthenaGlanceReport.find(nil, :params => { :eventId => self.id, :organizationId => self.organization_id })
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