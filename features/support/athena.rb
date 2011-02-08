module AthenaHelpers
  def setup_event(event)
    current_event(event)
    FakeWeb.register_uri(:post, "http://localhost/stage/events/.json", :body => current_event.encode)
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?producerPid=eq#{current_event.producer_pid}&isTemplate=eqtrue", :body => "[]")
    FakeWeb.register_uri(:get, "http://localhost/stage/events/.json?producerPid=eq#{current_event.producer_pid}", :body => "[#{current_event.encode}]")
  end

  def event_from_table_row(attributes)
    attributes.merge!(:producer_pid => @user.athena_id.to_s)
    Factory(:athena_event_with_id, attributes)
  end

  def current_event(event = nil)
    return @current_event if event.nil?
    @current_event = event
  end

  def setup_charts(charts = [])
    body = charts.collect { |p| p.encode }.join(",")
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
    charts.each do |chart|
      FakeWeb.register_uri(:get, "http://localhost/stage/sections/.json?chartId=eq#{chart.id}", :body => "[#{Factory(:athena_section_with_id).encode}]")
    end
    charts
  end

  def setup_performances(performances = [])
    body = performances.collect { |p| p.encode }.join(",")
    FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
    current_performances(performances)
  end

  def current_performances(performances = [])
    return @current_performances if performances.empty?
    @current_performances = performances
  end
end

World(AthenaHelpers)
