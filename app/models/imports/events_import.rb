class EventsImport < Import
  def kind
    "events"
  end
  
  def events_hash
    return @events if @events
    @events = {}
    parsed_rows.each do |row|
      key = (row.event_name || "") + (row.venue_name || "") + (row.show_date.to_s || "")
      @events[key] ||= []
      @events[key] << row
    end
    @events
  end
end