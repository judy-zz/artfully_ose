class MigrateVenues < ActiveRecord::Migration
  def self.up
    Event.unscoped.all.each do |event|
      venue = Venue.new({:name              => event.venue_name, 
                         :organization_id   => event.organization_id,
                         :time_zone         => event.attributes['time_zone'],
                         :state             => event.state,
                         :city              => event.city})
      venue.save
      event.venue_name = nil
      event.venue = venue
      event.save
    end
  end

  def self.down
  end
end
