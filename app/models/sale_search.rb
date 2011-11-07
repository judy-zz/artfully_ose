class SaleSearch

  attr_reader :start, :stop

  def initialize(start, stop, organization)
    @start = start_with(start)
    @stop  = stop_with(stop)
    @organization = organization
    @results = yield(results) if block_given?
  end

  def results
    @results ||= Order.in_range(@start, @stop, @organization.id).select(&:has_ticket?)
  end

  private

  def start_with(start)
    start.present? ? Time.zone.parse(start) : default_start
  end

  def stop_with(stop)
    stop.present? ? Time.zone.parse(stop) + 1.day - 1.minute : default_stop
  end

  def default_start
    DateTime.now.in_time_zone(Time.zone).beginning_of_month
  end

  def default_stop
    DateTime.now.in_time_zone(Time.zone).end_of_day
  end
end